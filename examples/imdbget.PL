#!/usr/bin/perl -w

use strict;
use IMDb;

my $id = shift @ARGV;

my $imdb = new IMDb 'title', "$id" 
    or die "can't create an IMDb object";

foreach(qw(title year cover_url rating votes genres))
{
    printf "%s: %s\n", ucfirst $_, join(', ', $imdb->$_());
}

foreach($imdb->get_character_fields)
{
    print "-------------------------------------\n";
    print ucfirst $_ . ":\n";
    print "-------------------------------------\n";
    foreach($imdb->$_())
    {
        print "$_->{name} aka $_->{role}\n";
    }
}
