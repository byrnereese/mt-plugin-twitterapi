#!/usr/bin/perl -w

use strict;

use Net::Twitter;

my $nt = Net::Twitter->new(
   apiurl   => "http://api.localhost",
   username => "byrnereese",
   password => "obp1dzbe",
);

eval {
    my $result = $nt->public_timeline();
    use Data::Dumper;
    print "Result: " . Dumper($result) . "\n";
};
if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');
    warn "HTTP Response Code: ", $err->code, "\n",
         "HTTP Message......: ", $err->message, "\n",
         "Twitter error.....: ", $err->error, "\n";
}
