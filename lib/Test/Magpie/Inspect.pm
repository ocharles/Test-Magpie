package Test::Magpie::Inspect;
use Moose;
use namespace::autoclean;

use aliased 'Test::Magpie::Invocation';

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Map );

use List::AllUtils qw( first );
use Moose::Util qw( find_meta );
use Test::Magpie::Util qw( extract_method_name );

with 'Test::Magpie::Role::HasMock';

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $method_name = extract_method_name($AUTOLOAD);

    my $meta = find_meta($self);
    my $mock = $meta->find_attribute_by_name('mock')->get_value($self);
    my $invocations = find_meta($mock)->find_attribute_by_name('invocations')
        ->get_value($mock);

    my $inspect = Invocation->new(
        method_name => $method_name,
        arguments => \@_
    );

    return first { $inspect->satisfied_by($_) } @$invocations;
}

1;

