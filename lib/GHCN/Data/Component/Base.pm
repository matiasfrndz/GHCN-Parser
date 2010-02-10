package GHCN::Data::Component::Base;
use base qw(DBIx::Class);

use strict;
use warnings;

use XML::LibXML;

sub safe_classname {
        my $self = shift;

        my $class = ref($self) || $self;
        $class =~ s/::/-/g;
        return $class;
}

sub to_dom {
        my $self = shift;

        my $objectname = $self->safe_classname();
        my $document = XML::LibXML->createDocument("1.0", "UTF-8");

        my $class = ref($self) || $self;
        my $object = $document->createElement($objectname);

        foreach my $column_name ($self->columns()) {
                my $value = $self->get_column($column_name);
                $value = '' unless (defined($value));
                my $column = $document->createElement($column_name);
                $column->appendText($value);
                $object->appendChild($column);
        }
        return $object;
}

1;