package Test::Magpie::Inspect;
# ABSTRACT: Inspect method invocations on mock objects

use Moose;
use namespace::autoclean;

use aliased 'Test::Magpie::Invocation';

use List::Util qw( first );
use Test::Magpie::Util qw( extract_method_name get_attribute_value );

with 'Test::Magpie::Role::HasMock';

our $AUTOLOAD;

sub AUTOLOAD {
    my $self = shift;

    my $inspect = Invocation->new(
        method_name => extract_method_name($AUTOLOAD),
        arguments   => \@_,
    );

    my $mock        = get_attribute_value($self, 'mock');
    my $invocations = get_attribute_value($mock, 'invocations');

    return first { $inspect->satisfied_by($_) } @$invocations;
}

__PACKAGE__->meta->make_immutable;
1;
