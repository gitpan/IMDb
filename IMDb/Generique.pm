package IMDb::Generique;

use 5.005;
use strict;
use vars qw($AUTOLOAD);
use Carp;
use LWP::UserAgent;
use XML::LibXML 1.52;

$IMDb::Ua      = new LWP::UserAgent requests_redirectable => [];
$IMDb::Parser  = new XML::LibXML;

sub fields
{
    return();
}

sub search
{
    return();
}

sub new 
{       
    my($proto, $id) = @_;
    my $class  = ref $proto || $proto;
    my $self   = {};
    bless $self, $class;
    return $self->init($id);
}

sub init
{
    my($self, $id) = @_;
    $self->{id} = $id;
    return $self;
}

sub id
{
    return $_[0]->{id};
}

sub type
{
    return(lc((split(/::/, ref($_[0])))[-1]));
}

sub AUTOLOAD
{
    my($self) = @_;
    my $type = ref($self)
        or croak "$self is not an object";

    my $name = $AUTOLOAD;
    $name =~ s/.*://;   # strip fully-qualified portion

    return if $name eq 'DESTROY';
    unless(grep($name eq $_, $self->fields))
    {
       croak "Can't access `$name' field in class $type";
    }

    if(!ref $self->{$name})
    {
        return $self->{$name};
    }
    elsif(ref $self->{$name} eq 'ARRAY')
    {
        return @{$self->{$name}};
    }
}

1;
