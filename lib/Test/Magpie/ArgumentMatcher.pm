package Test::Magpie::ArgumentMatcher;

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw( anything )],
};

sub anything {
    bless sub { return (1,()) }, __PACKAGE__;
}

sub match {
    my ($self, @input) = @_;
    return $self->(@input);
}

1;
