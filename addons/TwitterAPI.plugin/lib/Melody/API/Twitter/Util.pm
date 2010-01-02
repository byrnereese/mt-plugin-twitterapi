package Melody::API::Twitter::Util;

use strict;

use base 'Exporter';
use MT::Util qw( format_ts );
use MT::I18N qw( length_text substr_text );

our @EXPORT_OK =
  qw( serialize_author twitter_date truncate_tweet serialize_entries is_number load_friends load_followers latest_status );

sub latest_status {
    my ($user) = @_;
    return MT->model('entry')->load( { author_id => $user->id,
                                       status => 2 },
                                     { sort_by => 'created_on',
                                       direction => 'descend',
                                       limit => 1 } );
}

sub load_friends {
    my ($user) = @_;
    my @following =
      MT->model('tw_follower')
      ->load(
        { follower_id => $user->id },
        { sort_by => 'created_on',
          direction => 'descend' } );
    # TODO - the hash does not preserve order!!! Doh.
    my %hash = ();
    %hash = map { $_->followee_id => $_ } @following;
    return \%hash;
}


sub load_followers {
    my ($user) = @_;
    my @followers =
      MT->model('tw_follower')
      ->load(
        { followee_id => $user->id },
        { sort_by => 'created_on',
          direction => 'descend' } );
    # TODO - the hash does not preserve order!!! Doh.
    my %hash = ();
    %hash = map { $_->follower_id => $_ } @followers;
    return \%hash;
}

sub truncate_tweet {
    my ($str) = @_;
    return ( 0, '' ) unless $str;
    if ( 140 < length_text($str) ) {
        return ( 1, substr_text( $str, 0, 140 ) );
    }
    else {
        return ( 0, $str );
    }
}

sub twitter_date {
    my ($ts) = @_;
    return format_ts( '%a %b %e %H:%M:%S %Y', $ts );
}

sub is_number {
    my ($n) = @_;
    return $n + 0 eq $n;
}

sub serialize_entries {
    my ($entries) = @_;
    my $statuses = [];
    foreach my $e (@$entries) {
        my ( $trunc, $txt ) = truncate_tweet( $e->text );
        push @$statuses, {
            created_at => twitter_date( $e->created_on ),
            id         => $e->id,
            text       => $txt,
            source =>
              'Melody',  # TODO - replace with a meta data field I should create
            truncated => ( $trunc ? 'true' : 'false' ),
            in_reply_to_status_id   => '',
            in_reply_to_user_id     => '',
            favorited               => 'false',
            in_reply_to_screen_name => '',
            user                    => serialize_author( $e->author ),
            geo                     => undef,
        };
    }
    return $statuses;
}

sub serialize_author {
    my ($a) = @_;
    $a ||= ();
    return {
        id                => $a->id,
        name              => $a->nickname,
        screen_name       => $a->name,
        location          => '',
        description       => '',
        profile_image_url => '',
        url               => $a->url,
        protected         => 'false',
        created_at        => twitter_date( $a->created_on ),

        #        followers_count,
        #        profile_background_color,
        #        profile_text_color,
        #        profile_link_color,
        #        profile_sidebar_fill_color,
        #        profile_sidebar_border_color,
        #        friends_count,
        #        favourites_count,
        #        utc_offset,
        #        time_zone,
        #        profile_background_image_url,
        #        profile_background_tile,
        #        statuses_count,
        #        notifications,
        #        following,
        #        verified,
    };
}

1;
