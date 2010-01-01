package Melody::API::Twitter::Friends;

use base qw( Melody::API::Twitter );
use Melody::API::Twitter::Util qw( serialize_author twitter_date truncate_tweet serialize_entries is_number );

###########################################################################

=head2 friendships/create

Allows the authenticating users to follow the user specified in the ID parameter.  
Returns the befriended user in the requested format when successful.  
Returns a string describing the failure condition when unsuccessful. 
If you are already friends with the user an HTTP 403 will be returned.

 
URL:http://twitter.com/friendships/create/id.format
 
Formats: xml, json
 
HTTP Method(s): POST
 
Requires Authentication: true
 
API rate limited: false
 
B<Parameters:>

One of the following is required:

=over 4

=item id

Required. The ID or screen name of the user to befriend. 

=item user_id

Required. Specfies the ID of the user to befriend. Helpful for disambiguating when a 
valid user ID is also a valid screen name.

=item screen_name

Required. Specfies the screen name of the user to befriend. Helpful for disambiguating 
when a valid screen name is also a user ID.

=item follow

Optional. Enable delivery of statuses from this user to the authenticated user's device; 
tweets sent by the user being followed will be delivered to the caller of this endpoint's 
phone as SMSes.  See notifications/follow for more info.

=back
 
B<Usage notes:>

This method is subject to update limits. An HTTP 403 will be returned if this limit as been hit.

=cut

sub create {
    my $app = shift;
    my ($params) = @_;
}

###########################################################################

=head2 friendships/destroy 
=cut

###########################################################################

=head2 friendships/exists
=cut

###########################################################################

=head2 friendships/show 
=cut

###########################################################################

1;
__END__
