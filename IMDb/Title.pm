package IMDb::Title;

use 5.005;
use strict;
use base qw(IMDb::Generique);

sub title_fields
{
    return
    qw(
        title
        year
        cover_url
        rating
        votes
        genres
    );
}

sub people_fields
{
    return
    qw(
        cast
        directors
        writers
        producers
        editors
        original_composers
        cinematographers
        casting-directors
        art-directors
        set-decorators
        costume-designers
        make-up-department
        production-managers
        assistant-directors
        art-department
        sound-department
        special-effects-department
        visual-effects-department
        stunts
        miscellaneous
    );
}

sub fields
{
    my($self) = @_;
    return ($self->title_fields, $self->people_fields);
}

=pod

=head2 SEARCH

    IMDb::Title::search($string);

$string is the string to search for.

=cut

sub search
{
    my($string) = @_;
    my @found;

    my $response =
        $IMDb::Ua->get('http://us.imdb.com/Find?select=Titles&for='.$string);

    if($response->is_redirect)
    {
        if($response->header('location') =~ /\/Title\?(\d+)/)
        {
            push @found, $1;
        }
    }
    elsif($response->is_success)
    {
        my $doc = $IMDb::Parser->parse_html_string($response->content);
        foreach my $anode (@{$doc->find('//a[starts-with(@href, "/Title?")]')})
        {
            my $attr = $anode->getAttributeNode('href');
            if(defined $attr && $attr->value =~ /^\s*\/Title\?(\d+)/)
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
        $IMDb::Ua->get('http://us.imdb.com/Details?'.$id) or return;
#                 print $response->content,"\n";

    if($response->is_success)
    {
        my $doc = $IMDb::Parser->parse_html_string($response->content);

        # get title
        my $title_node =
            $doc->findnodes('//strong[@class = "title"]')->get_node(1);
        if(defined $title_node)
        {
            $self->{title} = $title_node->textContent;
            $self->{title} =~ s/\s*\(\d{2,4}\)\s*$//;
        }

        # get year
        $self->{year} = (_get_href($doc, '/Sections/Years/', '/'))[0];

        # get cover
        my $cover_node =
            $doc->findnodes('//img[@alt = "cover"]')->get_node(1);
        if(defined $cover_node)
        {
            $self->{cover_url} = $cover_node->getAttributeNode('src')->value;
        }

        # get genres
        @{$self->{genres}} = _get_href($doc, '/Sections/Genres/', '/');

        # get peoples
        foreach($self->people_fields)
        {
            $self->{$_} = _get_people_group($doc, $_);
        }

        # get rating
        $response->content =~ /<B>(\d(?:\.\d)?)<\/B>\/10\s+\((\d+)\s+votes\)/i;
        $self->{rating} = $1;
        $self->{votes}  = $2;

        return $self;
    }
}

sub _get_people_group
{
    my($doc, $anchor) = @_;
    my @peoples;
    my $node_anchor =
        $doc->findnodes(qq(//a[\@name = "$anchor"]))->get_node(1);
    return unless defined $node_anchor;
    my $node_container = $node_anchor->parentNode;
    # search for container (table that contains the anchor)
    while(defined $node_container 
        && $node_container->nodeName ne 'table')
    {
        $node_container = $node_container->parentNode;
    }
    my $node_list =
        $node_container->findnodes('./descendant::node()/a[starts-with(@href, "/Name?")]');
    foreach my $n ($node_list->get_nodelist)
    {
        my $set = {name => '', aka => undef};
        $n->getAttributeNode('href')->value =~ /^\s*\/Name\?(.*)\s*$/;
        # used for construct IMDb::People object
        $set->{id} = $1;
        $set->{name} = $n->textContent;
        my $role_node = $n->parentNode->nextSibling->nextSibling;
        if(defined $role_node)
        {
            $set->{role} = $role_node->textContent;
        }
        push @peoples, $set;
    }

    return \@peoples;
}

sub _get_href
{
    my($node, $prefix, $suffix) = @_;
    $suffix = '' unless defined $suffix;
    my @result;
    my $nodelist =
        $node->findnodes(sprintf('//a[starts-with(@href, "%s")]', $prefix));
    foreach($nodelist->get_nodelist)
    {
        $_->getAttributeNode('href')->value =~ /^\s*$prefix(.*)$suffix\s*$/;
        push @result, $1;
    }
    return @result;
}

1;
