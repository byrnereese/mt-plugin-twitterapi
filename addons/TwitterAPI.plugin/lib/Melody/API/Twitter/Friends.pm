package Melody::API::Twitter::Friends;

use base qw( Melody::API::Twitter );
use Melody::API::Twitter::Util
  qw( serialize_author twitter_date truncate_tweet serialize_entries is_number );

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
    return unless $app->SUPER::authenticate();

    my ($follower,$followee);
    if ( $params->{id} ) {
        if ( is_number( $params->{id} ) ) {
            $followee = $params->{id};
        }
        else {
            my $user = MT->model('author')->load( { name => $params->{id} } );
            unless ($user) {
                return $app->error( 404,
                    'User ' . $params->{id} . ' not found.' );
            }
            $followee = $user->id;
        }
    }
    if ( $params->{user_id} && is_number( $params->{user_id} )) {
        $followee = $user->id;
    }
    if ( $params->{screen_name} ) {
        my $user = MT->model('author')->load( { name => $params->{id} } );
        unless ($user) {
            return $app->error( 404,
                                'User ' . $params->{id} . ' not found.' );
        }
        $followee = $user->id;
    }
    $follower = $app->user->id;

    unless ( MT->model('author')->exist( $followee ) ) {
        return $app->error( 404,
                            'The person you wish to follow does not exist.' );
    }
    

    my $foll;
    $foll = MT->model('tw_follower')->load(
        {
            follower_id => $follower,
            followee_id => $followee,
        }
    );
    unless ($foll) {
        $foll = MT->model('tw_follower')->new;
        $foll->follower_id( $follower );
        $foll->followee_id( $followee );
# TODO - authentication layer is not properly seeding context. audit rows now showing ownership properly
        $foll->save;
    }
    my $user = MT->model('author')->load( $followee );
    return { user => serialize_author( $user ) };
}

###########################################################################

=head2 friendships/destroy 

Allows the authenticating users to unfollow the user specified in the ID parameter.  
Returns the unfollowed user in the requested format when successful.  Returns a 
string describing the failure condition when unsuccessful.

 
URL: http://twitter.com/friendships/destroy/id.format
 
Formats: xml, json
 
HTTP Method(s): POST, DELETE
 
Requires Authentication: true
 
API rate limited: false
 
B<Parameters:>

=over 4

=item id

Required. The ID or screen name of the user to unfollow. 

=item user_id

Required. Specfies the ID of the user to unfollow. Helpful for disambiguating when a valid user ID is also a valid screen name.

=item screen_name

Required. Specfies the screen name of the user to unfollow. Helpful for disambiguating when a valid screen name is also a user ID.

=back
 
=cut

sub destroy {
    my $app = shift;
    my ($params) = @_;    # this method takes no input
    return unless $app->SUPER::authenticate();

    my $id = $params->{id};
    my $u  = MT->model('author')->load($id);
    unless ($u) {
        return $app->error( 404, 'Status message ' . $id . ' not found.' );
    }
    my $foll =
      MT->model('tw_follower')
      ->load(
        { follower_id => $app->user->id, 
          followee_id => $id, } );
    $foll->remove;

    return { user => serialize_author($u) };
}

###########################################################################

=head2 friendships/exists

Tests for the existence of friendship between two users. Will return true if 
user_a follows user_b, otherwise will return false.
 
URL: http://twitter.com/friendships/exists.format
 
Formats: xml, json
 
HTTP Method(s): GET
 
Requires Authentication: true if user_a or user_b is protected
 
API rate limited: true
 
B<Parameters:>

=over 4

=item user_a

Required.  The ID or screen_name of the subject user.

=item user_b

Required.  The ID or screen_name of the user to test for following.

=back

=cut

sub exists {
    my $app = shift;
    my ($params) = @_;    # this method takes no input
    return unless $app->SUPER::authenticate();

    my $a = $params->{user_a};
    my $b = $params->{user_b};
    my $exists = (
      MT->model('tw_follower')
      ->exist(
        { follower_id => $a, 
          followee_id => $b } ) ? 'true' : 'false');

    return { friends =>  $exists };
}

###########################################################################

=head2 friendships/show 

=cut

sub show {
    my $app = shift;
    my ($params) = @_;
    return unless $app->SUPER::authenticate();

    local ($source, $target) = (undef,undef);
    foreach my $var (qw( source target )) {
        if ( $params->{$var.'_id'} ) {
            if ( is_number( $params->{$var.'_id'} ) ) {
                $$var = $params->{$var.'_id'};
            }
        }
        if ( $params->{$var.'_screen_name'} ) {
            my $user = MT->model('author')->load( { name => $params->{$var.'_screen_name'} } );
            unless ($user) {
                return $app->error( 404,
                                    "User ($var)" . $params->{$var.'_screen_name'} . ' not found.' );
            }
            $$var = $user->id;
        }
    }
    $source = $app->user->id unless $source;
    # TODO - return 403 if !$source and user is unauthed

    my $source_user = MT->model('author')->load( $source );
    unless ($source_user) {
        return $app->error( 404,
                            "Source user not found." );
    }
    my $target_user = MT->model('author')->load( $target );
    unless ($target_user) {
        return $app->error( 404,
                            "Target user not found." );
    }

    my $source_rel = MT->model('tw_follower')->load({
        follower_id => $source,
        followee_id => $target,
    });
    my $target_rel = MT->model('tw_follower')->load({
        follower_id => $target,
        followee_id => $source,
    });

    return {
        relationship => {
            source => {
                id => $source,
                screen_name => $source_user->name,
                following => $source_rel ? 'true' : 'false',
                followed_by => $target_rel ? 'true' : 'false',
                notifications_enabled => 'false'
            }, 
            target => {
                id => $target,
                screen_name => $target_user->name,
                following => $target_rel ? 'true' : 'false',
                followed_by => $source_rel ? 'true' : 'false',
                notifications_enabled => 'false'
            }
        }
    };
}

###########################################################################

1;
__END__
