package Melody::API::Twitter::Account;

use base qw( Melody::API::Twitter );
use Melody::API::Twitter::Util
  qw( serialize_author twitter_date truncate_tweet serialize_entries is_number );

###########################################################################

=head2 account/verify_credentials 

Returns an HTTP 200 OK response code and a representation of the requesting user 
if authentication was successful; returns a 401 status code and an error message 
if not.  Use this method to test if supplied user credentials are valid.
 
URL: http://twitter.com/account/verify_credentials.format
 
Formats: xml, json
 
HTTP Method(s): GET
 
Requires Authentication: true
 
API rate limited: false
 
B<Geolocation:>

The <user> object contains the geo_enabled flag which, by default is false for all users. 
For more information, see the statuses/update method for more information.
 
=cut

sub verify_credentials {
    my $app = shift;
    my ($params) = @_;
    return unless $app->SUPER::authenticate();

    my $user = $app->user;
    return { user => serialize_author( $user ) };

}

###########################################################################

=head2 account/rate_limit_status
=cut

###########################################################################

=head2 account/end_session
=cut

###########################################################################

=head2 account/update_delivery_device 
=cut

###########################################################################

=head2 account/update_profile_colors 
=cut

###########################################################################

=head2 account/update_profile_image 
=cut

###########################################################################

=head2 account/update_profile_background_image
=cut

###########################################################################

=head2 account/update_profile 
=cut

###########################################################################

1;
__END__
