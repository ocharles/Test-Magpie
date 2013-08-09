package Test::Magpie::Inspect;
# ABSTRACT: Inspect method calls on mock objects

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
        name => extract_method_name($AUTOLOAD),
        args => \@_,
    );

    my $mock  = get_attribute_value($self, 'mock');
    my $calls = get_attribute_value($mock, 'calls');

    return first { $inspect->satisfied_by($_) } @$calls;
}

__PACKAGE__->meta->make_immutable;
1;
