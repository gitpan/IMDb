#!/usr/bin/perl -w

use strict;
use IMDb;

my $search = shift @ARGV;

my @ids = IMDb::search('title', $search);

foreach my $id (@ids)
{
    my $imdb = new IMDb 'title', $id 
        or die "can't create an IMDb object";

    printf "%s: %s (%d)\n", $id, $imdb->title, $imdb->year;
}
