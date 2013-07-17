package Test::Magpie::Role::MethodCall;
# ABSTRACT: A role that represents a method call
use Moose::Role;
use namespace::autoclean;

use aliased 'Test::Magpie::ArgumentMatcher';

use Devel::PartialDump;
use MooseX::Types::Moose qw( ArrayRef Str );
use Test::Magpie::Util qw( match );

has 'method_name' => (
    isa => Str,
    is => 'ro',
    required => 1
);

has 'arguments' => (
    traits => [ 'Array' ],
    isa => ArrayRef,
    default => sub { [] },
    handles => {
        arguments => 'elements'
    }
);

sub as_string {
    my $self = shift;
    return $self->method_name .
        '(' . Devel::PartialDump->new->dump($self->arguments) . ')';
}

sub satisfied_by {
    my ($self, $invocation) = @_;

    return unless $invocation->method_name eq $self->method_name;

    my @input = $invocation->arguments;
    my @expected = $self->arguments;
    while (@input && @expected) {
        my $matcher = shift @expected;

        if (ref($matcher) eq ArgumentMatcher) {
            @input = $matcher->match(@input);
        }
        else {
            my $value = shift @input;
            return '' if !match($value, $matcher);
        }
    }
    return @input == 0 && @expected == 0;
}

1;

=head1 INTERNAL

This class is internal and not meant for use outside Magpie.

=method as_string

Stringifies this method call to something that roughly resembles what you'd type
in Perl.

=method satisfied_by (MethodCall $invocation)

Returns true if the given $invocation would satisfy this method call. Note that
while the $invocation could have arguments matchers in C<arguments>, they will
be passed into this method calls argument matcher. Which basically means, it
probably won't work.

=attr arguments

An array reference of arguments, or argument matchers.

=attr method_name

The name of the method.

=cut
