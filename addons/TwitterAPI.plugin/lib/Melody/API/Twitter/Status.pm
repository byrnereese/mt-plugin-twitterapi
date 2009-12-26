package Melody::API::Twitter::Status;

use base qw( Melody::API::Twitter );
# TODO - can this be loaded by parent?
use MT::Util qw( encode_xml format_ts );
use MT::I18N qw( length_text substr_text );

sub _truncate {
    my ($str) = @_;
    if (140 < length_text($str)) {
        return (1, substr_text($str, 0, 140));
    } else {
        return (0, $str);
    }
}

=head2 statuses/public_timeline

URL: http://twitter.com/statuses/public_timeline.format
 
Formats: xml, json, rss, atom 
 
HTTP Method(s): GET
 
Requires Authentication (about authentication): false
 
API rate limited (about rate limiting): true
 
Response (about return values): 

XML example (truncated):
<?xml version="1.0" encoding="UTF-8"?>
<statuses>
     <status>
<created_at>Tue Apr 07 22:52:51 +0000 2009</created_at>
<id>1472669360</id>
<text>At least I can get your humor through tweets. RT @abdur: I don't mean this in a bad way, but genetically speaking your a cul-de-sac.</text>
<source>&lt;a href="http://www.tweetdeck.com/">TweetDeck&lt;/a></source>
<truncated>false</truncated>
<in_reply_to_status_id></in_reply_to_status_id>
<in_reply_to_user_id></in_reply_to_user_id>
<favorited>false</favorited>
<in_reply_to_screen_name></in_reply_to_screen_name>
<user>
<id>1401881</id>
 <name>Doug Williams</name>
 <screen_name>dougw</screen_name>
 <location>San Francisco, CA</location>
 <description>Twitter API Support. Internet, greed, users, dougw and opportunities are my passions.</description>
 <profile_image_url>http://s3.amazonaws.com/twitter_production/profile_images/59648642/avatar_normal.png</profile_image_url>
 <url>http://www.igudo.com</url>
 <protected>false</protected>
 <followers_count>1027</followers_count>
 <profile_background_color>9ae4e8</profile_background_color>
 <profile_text_color>000000</profile_text_color>
 <profile_link_color>0000ff</profile_link_color>
 <profile_sidebar_fill_color>e0ff92</profile_sidebar_fill_color>
 <profile_sidebar_border_color>87bc44</profile_sidebar_border_color>
 <friends_count>293</friends_count>
 <created_at>Sun Mar 18 06:42:26 +0000 2007</created_at>
 <favourites_count>0</favourites_count>
 <utc_offset>-18000</utc_offset>
 <time_zone>Eastern Time (US & Canada)</time_zone>
 <profile_background_image_url>http://s3.amazonaws.com/twitter_production/profile_background_images/2752608/twitter_bg_grass.jpg</profile_background_image_url>
 <profile_background_tile>false</profile_background_tile>
 <statuses_count>3390</statuses_count>
 <notifications>false</notifications>
 <following>false</following>
 <verified>true</verified>
</user>
<geo/>
     </status>
     ... truncated ...
</statuses>

=cut

use MT::Log::Log4perl qw( l4mtdump ); use Log::Log4perl qw( :resurrect ); our $logger ||= MT::Log::Log4perl->new();                                    

sub public_timeline {
    my @entries = MT->model('entry')->load({ });
    my @statusus;
    foreach my $e (@entries) {
        $logger->debug('Adding: ' . $e->title);
        my ($trunc, $txt) = _truncate( $e->text );
        push @statuses, { 
            status => {
                created_at => format_ts('%B %e, %Y %I:%M %p',$e->created_on),
#               id => $e->id,
                text => $txt,
                source => 'Melody', #$PRODUCT_NAME,
                truncated => ($trunc ? 'true' : 'false'),
                in_reply_to_status_id => '',
                in_reply_to_user_id => '',
                favorited => false,
                in_reply_to_screen_name => '',
                user => {
                    id => $e->author->id,
                    name => $e->author->nickname,
                    screen_name => $e->author->name,
                    location => '',
                    description => '',
                    profile_image_url => '',
                    url => $e->author->url,
                    protected => 'false',
                    
                },
                geo => undef,
            }
        };
    }
    return { statuses => \@statuses };
}

=head2 statuses/home_timeline
=cut

=head2 statuses/friends_timeline
=cut

=head2 statuses/user_timeline 
=cut

=head2 statuses/mentions
=cut

=head2 statuses/retweeted_by_me
=cut

=head2 statuses/retweeted_to_me
=cut

=head2 statuses/retweets_of_me
=cut

=head2 statuses/show
=cut
=head2 statuses/update
=cut
=head2 statuses/destroy  
=cut
=head2 statuses/retweet
=cut
=head2 statuses/retweets
=cut

1;
__END__
