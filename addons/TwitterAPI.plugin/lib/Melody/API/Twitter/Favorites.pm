package Melody::API::Twitter::Favorites;

use base qw( Melody::API::Twitter );
use Melody::API::Twitter::Util
  qw( serialize_author twitter_date truncate_tweet serialize_entries is_number );

###########################################################################

=head2 favorites

Returns the 20 most recent favorite statuses for the authenticating user or 
user specified by the ID parameter in the requested format.
 
URL: http://twitter.com/favorites.format
 
Formats: xml, json, rss, atom 
 
HTTP Method: GET
 
Requires Authentication: true
 
API rate limited: 1 call per request
 
B<Parameters:>

=over 4

=item id

Optional.  The ID or screen name of the user for whom to request a list of favorite statuses.

=item page

Optional. Specifies the page of favorites to retrieve.

=back
 
=cut

sub favorites {
    my $app = shift;
    my ($params) = @_;    # this method takes no input
    return unless $app->SUPER::authenticate();

    my ($params) = @_;
    my $terms = { obj_type => 'entry', };
    my $args = {
        sort_by   => 'created_on',
        direction => 'descend',
    };
    my $n    = 20;
    my $page = 1;
    if ( $params->{id} ) {

        if ( is_number( $params->{id} ) ) {
            $terms->{author_id} = $params->{id};
        }
        else {
            my $user = MT->model('author')->load( { name => $params->{id} } );
            unless ($user) {
                return $app->error( 404,
                    'User ' . $params->{id} . ' not found.' );
            }
            $terms->{author_id} = $user->id;
        }
    }
    if ( $params->{page} && is_number( $params->{page} ) ) {
        $page = $params->{page};
    }
    $args->{limit} = $n;
    $args->{offset} = ( $n * ( $page - 1 ) ) if $page > 1;

    my $iter =
      MT->model('tw_favorite')->load_iter( $terms, $args );    # load everything
    my @ids;

    my $i = 0;
  ENTRY: while ( my $f = $iter->() ) {
        push @ids, $f->obj_id;
        $i++;

        #      $iter->end, last if $n && $i >= $n;
    }

    my @entries = MT->model('entry')->load( { id => \@ids } );

    my $statusus;
    $statuses = serialize_entries( \@entries );
    foreach (@$statuses) { $_->{favorited} = 'true'; }
    return { statuses => { status => $statuses } };

}

###########################################################################

=head2 favorites/create  

Favorites the status specified in the ID parameter as the authenticating user. Returns the favorite status when successful.
method status | report a bug
 
URL: http://twitter.com/favorites/create/id.format
 
Formats: xml, json
 
HTTP Method(s): POST
 
Requires Authentication: true
 
API rate limited: false
 
B<Parameters:>

=over 4

=item id

Required.  The ID of the status to favorite. 

=back

=cut

sub create {
    my $app = shift;
    my ($params) = @_;    # this method takes no input
    return unless $app->SUPER::authenticate();

    my $id = $params->{id};
    my $e  = MT->model('entry')->load($id);
    unless ($e) {
        return $app->error( 404, 'Status message ' . $id . ' not found.' );
    }
    my $fav;
    $fav = MT->model('tw_favorite')->load(
        {
            obj_type  => 'entry',
            obj_id    => $id,
            author_id => $app->user->id,
        }
    );
    unless ($fav) {
        $fav = MT->model('tw_favorite')->new;
        $fav->author_id( $app->user->id );
        $fav->obj_type('entry');
        $fav->obj_id($id);

# TODO - authentication layer is not properly seeding context. audit rows now showing ownership properly
        $fav->save;
    }

    # TODO - this needs to accurately show favorite status
    my $statuses = serialize_entries( [$e] );
    return { status => @$statuses[0] };
}

###########################################################################

=head2 favorites/destroy 

Un-favorites the status specified in the ID parameter as the authenticating user. Returns the un-favorited status in the requested format when successful.
method status | report a bug
 
URL:
http://twitter.com/favorites/destroy/id.format
 
Formats: 
xml, json
 
HTTP Method(s): POST, DELETE
 
Requires Authentication: true
 
API rate limited: false
 
B<Parameters:>

=over 4

=item id

Required.  The ID of the status to un-favorite. 

=back

=cut

sub destroy {
    my $app = shift;
    my ($params) = @_;    # this method takes no input
    return unless $app->SUPER::authenticate();

    my $id = $params->{id};
    my $e  = MT->model('entry')->load($id);
    unless ($e) {
        return $app->error( 404, 'Status message ' . $id . ' not found.' );
    }
    my $fav =
      MT->model('tw_favorite')
      ->load(
        { obj_type => 'entry', obj_id => $id, author_id => $app->user->id } );
    $fav->remove;

    # TODO - this needs to accurately show favorite status
    my $statuses = serialize_entries( [$e] );
    return { status => @$statuses[0] };
}

###########################################################################

1;
__END__
