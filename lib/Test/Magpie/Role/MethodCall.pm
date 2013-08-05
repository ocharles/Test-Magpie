package Test::Magpie::Role::MethodCall;
# ABSTRACT: A role that represents a method call

use Moose::Role;
use namespace::autoclean;

use aliased 'Test::Magpie::ArgumentMatcher';

use Devel::PartialDump;
use MooseX::Types::Moose qw( ArrayRef Str );
use Test::Magpie::Util qw( match );

my $Dumper = Devel::PartialDump->new(objects => 0, stringify => 1);

has 'method_name' => (
    isa => Str,
    is  => 'ro',
    required => 1
);

has 'arguments' => (
    isa     => ArrayRef,
    traits  => ['Array'],
    handles => { arguments => 'elements' },
    default => sub { [] },
);

# Stringifies this method call to something that roughly resembles what you'd
# type in Perl.

sub as_string {
    my ($self) = @_;
    return $self->method_name . '(' . $Dumper->dump($self->arguments) . ')';
}

# Returns true if the given C<$invocation> would satisfy this method call.

sub satisfied_by {
    my ($self, $invocation) = @_;

    return unless $invocation->method_name eq $self->method_name;

    my @expected = $self->arguments;
    my @input    = $invocation->arguments;
    # invocation arguments can't be argument matchers
    ### assert: ! grep { ref($_) eq 'ArgumentMatcher' } @input

    while (@input && @expected) {
        my $matcher = shift @expected;

        if (ref($matcher) eq ArgumentMatcher) {
            @input = $matcher->match(@input);
        }
        else {
            my $value = shift @input;
            return if !match($value, $matcher);
        }
    }
    return @input == 0 && @expected == 0;
}

1;
