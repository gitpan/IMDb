use strict;
use ExtUtils::MakeMaker;

WriteMakefile
(
    NAME            => 'IMDb',
    DISTNAME        => 'IMDb',
    VERSION_FROM    => 'IMDb.pm', 
    PREREQ_PM       => {},
    ABSTRACT_FROM   => 'IMDb.pm',
    AUTHOR          => 'Olivier Poitrey <rs@rhapsodyk.net>',
);
