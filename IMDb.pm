package IMDb;

use strict;
use Carp;
$IMDb::VERSION = '0.01';

my %Loaded;
my @SubMods =
qw(
    IMDb::Title
    IMDb::People
);

sub _load
{
    my($type, $class) = @_;
    $type  = ucfirst $type;
    $class = 'IMDb' unless defined $class and length $class;
    $class = "${class}::$type";
    return $class if exists $Loaded{$class};
    croak "Can't load class `$class', not part of IMDb distribution"
        unless grep $class eq $_, @SubMods;
    eval("use $class");
    die $@ if($@);
    $Loaded{$class} = 1;
    return $class;
}

sub new
{
    my $class = shift;
    my $type  = shift;
    $class    = _load($type, $class);
    return new $class @_;
}

sub search
{
    my $type  = shift;
    my $class = _load($type);
    return eval($class.'::search(@_)');
}

1;

__END__

=head1 NAME

IMDb - Abstract class to query the Internet Movie Database

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Olivier Poitrey E<lt>rs@rhapsodyk.netE<gt>

=head1 AVAILABILITY

The official FTP location is:

B<ftp://ftp.rhapsodyk.net/pub/devel/perl/IMDb/>

Also available on CPAN.

anonymous CVS repository:

CVS_RSH=ssh cvs -d anonymous@cvs.rhapsodyk.net:/devel co IMDb

(supply an empty string as password)

CVS repository on the web:

http://www.rhapsodyk.net/cgi-bin/cvsweb/IMDb/

=head1 LICENCE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with the program; if not, write to the Free Software
Foundation, Inc. :

59 Temple Place, Suite 330, Boston, MA 02111-1307

=head1 COPYRIGHT

Copyright (C) 2002 - Olivier Poitrey
