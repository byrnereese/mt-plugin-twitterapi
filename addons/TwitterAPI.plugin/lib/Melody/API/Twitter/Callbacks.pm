package Melody::API::Twitter::Callbacks;

use strict;

sub entry_post_remove {
    my ( $cb, $obj ) = @_;
    MT->model('tw_favorite')->remove(
        {
            obj_type => 'entry',
            obj_id   => $obj->id,
        }
    );
    return 1;
}

sub author_post_remove {
    my ( $cb, $obj ) = @_;

    # Clean up user's favorites
    MT->model('tw_favorite')->remove( { author_id => $obj->id, } );

    # Clean up the list of people they are following
    MT->model('tw_follower')->remove( { followee_id => $obj->id, } );

    # Clean up the records of people following them
    MT->model('tw_follower')->remove( { follower_id => $obj->id, } );

    return 1;
}

1;
