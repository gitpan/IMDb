package IMDb::People;

use 5.005;
use strict;
use base qw(IMDb::Generique);

sub name_fields
{
    qw(
        cover_url
    );
}

sub fields
{
    my($self) = @_;
    return ($self->name_fields);
}

=pod

=head2 SEARCH

    IMDb::People::search($string);

$string is the string to search for.

=cut

sub search
{
    my($string) = @_;
    my @found;

    my $response =
        $IMDb::Ua->get('http://us.imdb.com/Find?select=People&for='.$string);

    if($response->is_success)
    {
        my $doc = $IMDb::Parser->parse_html_string($response->content);
        foreach my $anode (@{$doc->find('//a[starts-with(@href, "/Name?")]')})
        {
            my $attr = $anode->getAttributeNode('href');
            if(defined $attr && $attr->value =~ /^\s*\/Name\?(.*)\s*$/)
            {
                push @found, $1;
            }
        }
    }

    return @found;
}

sub init
{
    my $self = shift;
    $self->SUPER::init(@_) or return;
    my($id) = @_;

    my $response =
        $IMDb::Ua->get('http://us.imdb.com/Name?'.$id) or return;
#                 print $response->content,"\n";

    if($response->is_success)
    {
        my $doc = $IMDb::Parser->parse_html_string($response->content);

        # get cover
        my $cover_node =
            $doc->findnodes('//img[@alt = "Headshot"]')->get_node(1);
        if(defined $cover_node)
        {
            $self->{cover_url} = $cover_node->getAttributeNode('src')->value;
        }

        return $self;
    }
}

1;
