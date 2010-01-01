package Melody::Favorite;

use strict;
use base qw( MT::Object );

__PACKAGE__->install_properties({
    column_defs => {
        'id' => 'integer not null auto_increment',
        'author_id' => 'integer not null',
        'obj_id' => 'integer not null',
        'obj_type' => 'string(20)',
    },
    indexes => {
        author_id => 1,
        obj_id_and_type => {
            columns => [ 'author_id', 'obj_id', 'obj_type' ],
        },        
    },
    defaults => {
    },
    audit => 1,
    datasource => 'tw_favorites',
    primary_key => 'id',
});

sub class_label {
    MT->translate("Favorite");
}

sub class_label_plural {
    MT->translate("Favorites");
}

sub author {
    my $fav = shift;
    $fav->cache_property('author', sub {
        return undef unless $fav->author_id;
        my $req = MT::Request->instance();
        my $author_cache = $req->stash('author_cache');
        my $author = $author_cache->{$fav->author_id};
        unless ($author) {
            $author = MT->model('author')->load($fav->author_id)
                or return undef;
            $author_cache->{$fav->author_id} = $author;
            $req->stash('author_cache', $author_cache);
        }
        $author;
    });
}

sub object {
    my $fav = shift;
    my $class = $fav->obj_type;
    $fav->cache_property($class, sub {
        return undef unless $fav->obj_id;
        my $req = MT::Request->instance();
        my $cache = $req->stash($class . '_cache');
        my $obj = $cache->{$fav->obj_id};
        unless ($obj) {
            $obj = MT->model($class)->load($fav->obj_id)
                or return undef;
            $cache->{$fav->obj_id} = $obj;
            $req->stash($class . '_cache', $cache);
        }
        $obj;
    });
}

1;
__END__

=head1 NAME
                                                                                                                                                       
    Melody::Favorite - A favorite
