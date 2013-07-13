package Test::Magpie::Spy;
# ABSTRACT: A look into the invocation history of a mock for verifaciotn
use Moose;
use namespace::autoclean;

use aliased 'Test::Magpie::Invocation';

use List::AllUtils qw( first );
use MooseX::Types::Moose qw( ArrayRef Str );
use Test::Builder;
use Test::Magpie::Util qw( extract_method_name get_attribute_value );

with 'Test::Magpie::Role::HasMock';

my $TB = Test::Builder->new;

my %INVOCATION_TESTS = (
    at_least => sub {
        my ($n) = @_;
        return sub { $n <= $_[0] };
    },
    at_most => sub {
        my ($n) = @_;
        return sub { $n >= $_[0] };
    },
    times => sub {
        my ($n) = @_;
        return sub { $n == $_[0] };
    },
);

has 'name' => (
    isa => Str,
    is => 'bare',
);

has 'invocation_counters' => (
    isa => ArrayRef,
    is => 'bare',
    default => sub { [] },
);

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;
    my $args = $self->$orig(@_);

    # create invocation_counters out of times, at_least and at_most options
    my @invocation_counters;
    foreach (grep {defined $args->{$_}} qw[times at_least at_most]) {
        my $times = delete $args->{$_};

        # $times is a coderef if at_least() or at_most() are used
        push @invocation_counters,
            !ref($times) ? $INVOCATION_TESTS{$_}->($times) : $times;
    }
    $args->{ invocation_counters } = \@invocation_counters;

    return $args;
};

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $method_name = extract_method_name($AUTOLOAD);

    my $observe = Invocation->new(
        method_name => $method_name,
        arguments   => \@_,
    );

    my $mock = get_attribute_value($self, 'mock');
    my $invocations = get_attribute_value($mock, 'invocations');

    my $matches = grep { $observe->satisfied_by($_) } @$invocations;

    my $invocation_counters = get_attribute_value($self, 'invocation_counters');
    my $test = 1;
    foreach (@$invocation_counters) {
        $test &&= $_->($matches);
        last if ! $test;
    }

    my $name = get_attribute_value($self, 'name') ||
        sprintf("%s was invoked the correct number of times",
            $observe->as_string);

    $TB->ok($test, $name);
    return;
}

__PACKAGE__->meta->make_immutable;
1;

=head1 DESCRIPTION

Spy objects allow you to look inside a mock and verify that certain methods have
been called. You create these objects by using C<verify> from L<Test::Magpie>.

Spy objects do not have a public API as such; they share the same method calls
as the mock object itself. The difference being, a method call now checks that
the method was invoked on the mock at some point in time, and if not, fails a
test.

You may use argument matchers in verification method calls.

=cut

