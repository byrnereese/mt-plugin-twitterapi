package Melody::API::Twitter::Status;

use base qw( Melody::API::Twitter );
# TODO - can this be loaded by parent?
use MT::Util qw( encode_xml );
use Melody::API::Twitter::Util qw( serialize_author twitter_date truncate_tweet serialize_entries is_number );

=head2 statuses/public_timeline

Returns the 20 most recent statuses from non-protected users who have set a custom user icon. 
The public timeline is cached for 60 seconds so requesting it more often than that is a waste 
of resources.

URL: http://<api base URL>/statuses/public_timeline.<format>
 
Formats: xml, json, rss, atom 
 
Requires Authentication: false
 
API rate limited: true
 
Response: An array statuses.

=cut

sub public_timeline {
    my $app = shift;
    my ($params) = @_; # this method takes no input
    my $terms = {};
    my $args = {
        sort_by => 'created_on',
        direction => 'descend',
    };
    my $iter = MT->model('entry')->load_iter($terms,$args); # load everything
    my @entries;
    my $n = 20;
    my $i = 0;
    ENTRY: while (my $e = $iter->()) {
      push @entries, $e;
      $i++;
      $iter->end, last if $n && $i >= $n;
    }
    my $statusus;
    $statuses = serialize_entries( \@entries );
    return { statuses => { status => $statuses } };
}

###########################################################################

=head2 statuses/home_timeline

Returns the 20 most recent statuses, including retweets, posted by the authenticating user and 
that user's friends. This is the equivalent of /timeline/home on the Web.

Usage note: This home_timeline is identical to statuses/friends_timeline except it also contains 
retweets, which statuses/friends_timeline does not (for backwards compatibility reasons). In a 
future version of the API, statuses/friends_timeline will go away and be replaced by home_timeline.
 
URL: http://<base api URL>/1/statuses/home_timeline.<format>
 
Formats: xml, json, atom 
 
HTTP Method(s): GET
 
Requires Authentication: true
 
API rate limited: 1 call per request
 
B<Parameters:>

=over 4

=item since_id

Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID. 

=item max_id

Optional.  Returns only statuses with an ID less than (that is, older than) or equal to the specified ID.

=item count

Optional.  Specifies the number of statuses to retrieve. May not be greater than 200. 

=item page

Optional. Specifies the page of results to retrieve. Note: there are pagination limits.

=back
 
=cut

sub home_timeline {
    my $app = shift;
    return unless $app->SUPER::authenticate();
    my ($params) = @_;
    my $terms = {};
    my $args = {
        sort_by => 'created_on',
        direction => 'descend',
    };
    my $n = 20;
    my $page = 1;
    if ($params->{count} && is_number($params->{count}) && $params->{count} <= 200) {
        $n = $params->{count};
    }
    if ($params->{max_id}) {
        $terms->{id} = { '<=' => $params->{max_id} };
    }
    if ($params->{since_id}) {
        $terms->{id} = { '>' => $params->{since_id} };
    }
    if ($params->{page} && is_number($params->{page})) {
        $page = $params->{page};
    }
    $args->{limit} = $n;
    $args->{offset} = ($n * ($page - 1)) if $page > 1;

    my $iter = MT->model('entry')->load_iter($terms,$args); # load everything
    my @entries;

    my $i = 0;
    ENTRY: while (my $e = $iter->()) {
      push @entries, $e;
      $i++;
#      $iter->end, last if $n && $i >= $n;
    }
    my $statusus;
    $statuses = serialize_entries( \@entries );
    return { statuses => { status => $statuses } };
}

###########################################################################

=head2 statuses/friends_timeline
=cut

###########################################################################

=head2 statuses/user_timeline 
=cut

###########################################################################

=head2 statuses/mentions
=cut

###########################################################################

=head2 statuses/retweeted_by_me
=cut

###########################################################################

=head2 statuses/retweeted_to_me
=cut

###########################################################################

=head2 statuses/retweets_of_me
=cut

###########################################################################

=head2 statuses/show
=cut

###########################################################################

=head2 statuses/update
=cut

###########################################################################

=head2 statuses/destroy  
=cut

###########################################################################

=head2 statuses/retweet
=cut

###########################################################################

=head2 statuses/retweets
=cut

###########################################################################

1;
__END__
