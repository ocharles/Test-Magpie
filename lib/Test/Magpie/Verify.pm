package Test::Magpie::Verify;
# ABSTRACT: Verify interactions with a mock object by looking into its invocation history

use Moose;
use namespace::autoclean;

use aliased 'Test::Magpie::Invocation';

use MooseX::Types::Moose qw( Num Str CodeRef );
use Test::Builder;
use Test::Magpie::Types qw( NumRange );
use Test::Magpie::Util qw( extract_method_name get_attribute_value );

with 'Test::Magpie::Role::HasMock';

our $AUTOLOAD;

my $TB = Test::Builder->new;

has 'test_name' => (
    isa => Str,
    reader => '_test_name',
);

has 'times' => (
    isa => Num|CodeRef,
    reader => '_times',
);
has 'at_least' => (
    isa => Num,
    reader => '_at_least',
);
has 'at_most' => (
    isa => Num,
    reader => '_at_most',
);
has 'between' => (
    isa => NumRange,
    reader => '_between',
);

sub AUTOLOAD {
    my $self = shift;
    my $method_name = extract_method_name($AUTOLOAD);

    my $observe = Invocation->new(
        method_name => $method_name,
        arguments   => \@_,
    );

    my $mock        = get_attribute_value($self, 'mock');
    my $invocations = get_attribute_value($mock, 'invocations');

    my $matches = grep { $observe->satisfied_by($_) } @$invocations;

    my $test_name = $self->_test_name;

    if (defined $self->_times) {
        if ( CodeRef->check($self->_times) ) {
            # handle use of deprecated at_least() and at_most()
            $self->_times->(
                $matches, $observe->as_string, $test_name, $TB);
        }
        else {
            $test_name = sprintf '%s was called %u time(s)',
                $observe->as_string, $self->_times
                    unless defined $test_name;
            $TB->is_num( $matches, $self->_times, $test_name );
        }
    }
    elsif (defined $self->_at_least) {
        $test_name = sprintf '%s was called at least %u time(s)',
            $observe->as_string, $self->_at_least
                unless defined $test_name;
        $TB->cmp_ok( $matches, '>=', $self->_at_least, $test_name );
    }
    elsif (defined $self->_at_most) {
        $test_name = sprintf '%s was called at most %u time(s)',
            $observe->as_string, $self->_at_most
                unless defined $test_name;
        $TB->cmp_ok( $matches, '<=', $self->_at_most, $test_name );
    }
    elsif (defined $self->_between) {
        my ($lower, $upper) = @{$self->_between};
        $test_name = sprintf '%s was called between %u and %u time(s)',
            $observe->as_string, $lower, $upper
                unless defined $test_name;
        $TB->ok( $lower <= $matches && $matches <= $upper, $test_name );
    }
    return;
}

__PACKAGE__->meta->make_immutable;
1;
