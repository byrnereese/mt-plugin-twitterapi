package Melody::API::Twitter;

use strict;

use MT;
use MT::Util qw( encode_xml format_ts );
use MT::I18N qw( length_text substr_text );
use base qw( MT::App );

my($HAVE_XML_PARSER);
BEGIN {
    eval { require XML::Parser };
    $HAVE_XML_PARSER = $@ ? 0 : 1;
}

use MT::Log::Log4perl qw( l4mtdump ); use Log::Log4perl qw( :resurrect ); our $logger ||= MT::Log::Log4perl->new();                                    

sub init {
    my $app = shift;
    $logger ||= MT::Log::Log4perl->new(); #$logger->trace(); 
    $logger->debug( 'Initializing app...' );
    $app->{no_read_body} = 1
        if $app->request_method eq 'POST' || $app->request_method eq 'PUT';
    $app->SUPER::init(@_) or return $app->error("Initialization failed");
    $app->request_content
        if $app->request_method eq 'POST' || $app->request_method eq 'PUT';
    $app->add_methods(
        handle => \&handle,
        );
    $app->{default_mode} = 'handle';
    $app->{is_admin} = 0;
    $app->{warning_trace} = 0;
    $app;
}

our $SUBAPPS = {
    'trends' => 'Melody::API::Twitter::Trends',
    'statuses' => 'Melody::API::Twitter::Status',
    'direct_messages' => 'Melody::API::Twitter::DirectMessage',
    'users' => 'Melody::API::Twitter::User',
    'account' => 'Melody::API::Twitter::Account',
    'favorites' => 'Melody::API::Twitter::Favorites',
    'help' => 'Melody::API::Twitter::Help',
};

sub handle {
    my $app = shift;
    $logger->debug( 'Entering "handle"...' );
    my $out = eval {
        (my $pi = $app->path_info) =~ s!^/!!;
        $logger->debug( 'Path info: ' . $pi );
        $app->{param} = {};

        my ($subapp, $method, $id, $format);

        if ( ($subapp, $method, $id, $format) = ( $pi =~ /^([^\/]*)\/([^\/]*)\/([^\.]*)\.(.*)$/ ) ) {
            $logger->debug( "Sub app: $subapp, method: $method, id: $id, format: $format" );
        } elsif ( ($subapp, $method, $format) = ( $pi =~ /^([^\/]*)\/([^\.]*)\.(.*)$/ ) ) {
            $logger->debug( "Sub app: $subapp, method: $method, format: $format" );
        } elsif ( ($subapp, $format) = ( $pi =~ /^([^\.]*)\.(.*)$/ ) ) {
            $method = $subapp;
            $logger->debug( "Sub app: $subapp, method: $method, format: $format" );
        } else {
            $logger->debug( "Unrecognized query format." );
            # TODO - bail
        }
        $app->mode($method);

        my $args = {};
        for my $arg (split(';',$app->query_string)) {
            my($k, $v) = split(/=/, $arg, 2);
            $app->{param}{$k} = $v;
            $args->{$k} = $v;
        }
        if ($id) {
            $args->{id} = $id;
        }
        if (my $class = $SUBAPPS->{$subapp}) {
            eval "require $class;";
            bless $app, $class;
            $logger->debug( 'Reblessed app as ' . ref $app );
        }
        my $out;
        if ($app->can($method)) {
            $logger->debug( "It looks like app can process $method" );
            # Authentication should be defered to the designated handler since not
            # all methods require auth.
            use Data::Dumper;
            $logger->debug("Calling $method with args: " . Dumper($args) );
            $out = $app->$method($args);
        } else {
            $logger->debug( "Drat, app can't process $method" );
        }
        if ($app->{_errstr}) {
            $logger->debug( 'There was an error processing the request.' );
            return;
        }
        $logger->debug( 'Returning: ' . $out );
        return unless defined $out;
        my $out_enc;
        if (lc($format) eq 'json') {
            $app->response_content_type('application/json');
            $out_enc = MT::Util::to_json( $out );
        } elsif (lc($format) eq 'xml') {
            $app->response_content_type('text/xml');
            require XML::Simple;
            my $xml = XML::Simple->new;
            $out_enc = '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
            $out_enc .= $xml->XMLout( $out, NoAttr => 1, KeepRoot => 1, GroupTags => { statuses => 'status' } );
        } else {
            # TODO - respond with indication that it is unsupported format
            return $app->error(500, 'Unsupported format: ' . $format);
            $app->show_error("Internal Error");
            return;
        }
        return $out_enc;
    };
    if (my $e = $@) {
        $app->error(500, $e);
        $app->show_error("Internal Error");
    }
    return $out;
}

sub get_auth_info {
    my $app = shift;
    my %param;

    my $auth_header = $app->get_header('Authorization')
        or return undef;

    $logger->debug( 'Authorization header present: '.$auth_header );
    my ($type, $creds_enc) = split(" ",$auth_header);
    if (lc($type) eq 'basic') {
        require MIME::Base64;
        my $creds = MIME::Base64::decode_base64( $creds_enc );
        my ($username, $password) = split(':',$creds);
        $logger->debug( 'Username: '.$username );
        $logger->debug( 'Password (encoded): '.$password );
        
        # Lookup user record
        my $user = MT::Author->load({ name => $username, type => 1 })
            or return $app->auth_failure(403, 'Invalid login');
        $param{username} = $user->name;
        $app->user( $user );
        
        # Make sure use has an API Password set
        return $app->auth_failure(403, 'Invalid login. API Password not set.')
            unless $user->api_password;
        
        # Make sure user is active
        return $app->auth_failure(403, 'Invalid login. User is not active.')
            unless $user->is_active;
        
        # Check to see if passwords match
        return $app->auth_failure(403, 'Invalid login. Password mismatch.') 
            unless $user->api_password eq $password;
        
    } else {
        # Unsupported auth type
        # TODO: return unsupported
    }

    \%param;
}

sub authenticate {
    my $app = shift;

    $logger->debug( 'Attempting to authenticate user...' );

    my $auth = $app->get_auth_info
        or return $app->auth_failure(401, "Unauthorized");

#    if (my $blog_id = $app->{param}{blog_id}) {
#        $app->{blog} = MT->model('blog')->load($blog_id)
#            or return $app->error(400, "Invalid blog ID '$blog_id'");
#        $app->{user}
#        or return $app->error(403, "Authenticate");
#        if ($app->{user}->is_superuser()) {
#            $app->{perms} = MT->model('permission')->new;
#            $app->{perms}->blog_id($blog_id);
#            $app->{perms}->author_id($app->{user}->id);
#            $app->{perms}->can_administer_blog(1);
#            return 1;
#        }
#        my $perms = $app->{perms} = MT->model('permission')->load({
#            author_id => $app->{user}->id,
#            blog_id => $app->{blog}->id });
#        return $app->error(403, "Permission denied.") unless $perms && $perms->can_create_post;
#    }

    1;
}

sub auth_failure {
    my $app = shift;
    $logger->debug("There was an auth failure...");
    $app->set_header('WWW-Authenticate', 'Basic realm="api.localhost"');
    return $app->error(@_,1);
}

=head2

This is what a Twitter Error looks like in XML.

<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <request>/direct_messages/destroy/456.xml</request>
  <error>No direct message with that ID found.</error>
</hash>

=cut 

sub error {
    my $app = shift;
    my($code, $msg, $dont_send_body) = @_;
    $logger->debug("Processing error $code with message: $msg");
    return unless ref($app);
    if ($code && $msg) {
        $app->response_code($code);
        $app->response_message($msg);
        $app->{_errstr} = $msg;
    }
    elsif ($code) {
        return $app->SUPER::error($code);
    }
    return undef if $dont_send_body;
    return {
        request => $app->path_info,
        error   => $msg,
    };
}

sub show_error {
    my $app = shift;
    my($err) = @_;
    chomp($err = encode_xml($err));
    return <<ERR;
<error>$err</error>
ERR
}

=head2 search

URL:
http://search.twitter.com/search.format
 
Formats: 
json, atom 
 
HTTP Method:
GET
 
Requires Authentication (about authentication):
false
 
API rate limited (about rate limiting):
1 call per request
 
Parameters:

callback: Optional. Only available for JSON format. If supplied, the response will use the JSONP format with a callback of the given name.

lang: Optional: Restricts tweets to the given language, given by an ISO 639-1 code.

locale: Optional. Specify the language of the query you are sending (only ja is currently effective). This is intended for language-specific clients and the default should work in the majority of cases.

rpp: Optional. The number of tweets to return per page, up to a max of 100.

page: Optional. The page number (starting at 1) to return, up to a max of roughly 1500 results (based on rpp * page. Note: there are pagination limits.

since_id: Optional. Returns tweets with status ids greater than the given id.

geocode: Optional. Returns tweets by users located within a given radius of the given latitude/longitude.  The location is preferentially taking from the Geotagging API, but will fall back to their Twitter profile. The parameter value is specified by "latitide,longitude,radius", where radius units must be specified as either "mi" (miles) or "km" (kilometers). Note that you cannot use the near operator via the API to geocode arbitrary locations; however you can use this geocode parameter to search near geocodes directly.

show_user: Optional. When true, prepends "<user>:" to the beginning of the tweet. This is useful for readers that do not display Atom's author field. The default is false.

JSON example (truncated):
  {"results":[
     {"text":"@twitterapi  http:\/\/tinyurl.com\/ctrefg",
     "to_user_id":396524,
     "to_user":"TwitterAPI",
     "from_user":"jkoum",
     "id":1478555574,   
     "from_user_id":1833773,
     "iso_language_code":"nl",
     "source":"<a href="http:\/\/twitter.com\/">twitter<\/a>",
     "profile_image_url":"http:\/\/s3.amazonaws.com\/twitter_production\/profile_images\/118412707\/2522215727_a5f07da155_b_normal.jpg",
      "created_at":"Wed, 08 Apr 2009 19:22:10 +0000"},
     ... truncated ...],
     "since_id":0,
     "max_id":1480307926,
     "refresh_url":"?since_id=1480307926&q=%40twitterapi",
     "results_per_page":15,
     "next_page":"?page=2&max_id=1480307926&q=%40twitterapi",
     "completed_in":0.031704,
     "page":1,
     "query":"%40twitterapi"}
  }

=cut

sub search {

}

=head2 trends

Variants: trends/(current|daily|weekly)

=cut

sub trends {

}

1;
__END__
