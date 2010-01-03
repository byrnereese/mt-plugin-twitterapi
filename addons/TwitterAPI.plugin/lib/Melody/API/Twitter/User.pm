package Melody::API::Twitter::User;

use base qw( Melody::API::Twitter );
use Melody::API::Twitter::Util
  qw( serialize_author twitter_date truncate_tweet serialize_entries is_number load_friends load_followers latest_status );

###########################################################################

=head2 users/show 

Returns extended information of a given user, specified by ID or screen name 
as per the required id parameter.  The author's most recent status will be 
returned inline.
 
URL: http://twitter.com/users/show.format
 
Formats: xml, json
 
HTTP Method(s): GET
 
Requires Authentication: false (see usage notes)
 
API rate limited: 1 call per request
 
B<Parameters:>

=over 4

=item id

The ID or screen name of a user. 

=item user_id

Specfies the ID of the user to return. Helpful for disambiguating when a valid user ID is also a valid screen name.

=item screen_name

Specfies the screen name of the user to return. Helpful for disambiguating when a valid screen name is also a user ID.

=back 
 
B<Usage Notes:>

Requests for protected users without credentials from 1) the user requested or 
2) a user that is following the protected user will omit the nested status 
element. Only publicly available data will be returned in this case.

=cut

sub show {
    my $app = shift;

    # TODO - auth only if post is protected
    #    return unless $app->SUPER::authenticate();
    my ($params) = @_;
    my $id;
    if ( $params->{id} && is_number( $params->{id} ) ) {
        $id = $params->{id};
    }
    if ( $params->{user_id} && is_number( $params->{user_id} ) ) {
        $id = $params->{user_id};
    }
    if ( $params->{screen_name} ) {
        my $user =
          MT->model('author')->load( { name => $params->{screen_name} } );
        $id = $user->id if $user;
    }

    my $u = MT->model('author')->load($id);
    unless ($u) {
        return $app->error( 404, 'User not found.' );
    }
    my $uh     = serialize_author($u);
    my $latest = latest_status($u);
    if ($latest) {
        $uh->{status} = serialize_entries( [$latest] )->[0];
        delete %$uh->{status}->{user};
    }

    return { user => $uh };
}

###########################################################################

=head2 users/search
=cut

###########################################################################

1;
__END__
