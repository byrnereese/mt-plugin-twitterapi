package Melody::Follower;

use strict;
use base qw( MT::Object );

__PACKAGE__->install_properties(
    {
        column_defs => {
            'id'          => 'integer not null auto_increment',
            'followee_id' => 'integer not null',
            'follower_id' => 'integer not null',
        },
        indexes => {
            followee_id => 1,
            follower_id => 1,
        },
        defaults    => {},
        audit       => 1,
        datasource  => 'tw_followers',
        primary_key => 'id',
    }
);

sub class_label {
    MT->translate("Follower");
}

sub class_label_plural {
    MT->translate("Followers");
}

sub follower {
    my $f = shift;
    return $f->_author('follower_id');
}

sub followee {
    my $f = shift;
    return $f->_author('followee_id');
}

sub _author {
    my $f = shift;
    my ($str) = @_;
    $f->cache_property(
        'author',
        sub {
            return undef unless $f->$str();
            my $req          = MT::Request->instance();
            my $author_cache = $req->stash('author_cache');
            my $author       = $author_cache->{ $f->$str() };
            unless ($author) {
                $author = MT->model('author')->load( $f->$str() )
                  or return undef;
                $author_cache->{ $f->$str() } = $author;
                $req->stash( 'author_cache', $author_cache );
            }
            $author;
        }
    );
}

1;
__END__

=head1 NAME
                                                                                                                                                       
    Melody::Favorite - A favorite
