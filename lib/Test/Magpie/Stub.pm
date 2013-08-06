package Test::Magpie::Stub;
# ABSTRACT: The declaration of a stubbed method

# Represents a stub method - a method that may have some sort of action when
# called. Stub methods are created by invoking the method name (with a set of
# possible argument matchers/arguments) on the object returned by C<when> in
# L<Test::Magpie>.
#
# Stub methods have a stack of executions. Every time the stub method is called
# (matching arguments), the next execution is taken from the front of the queue
# and called. As stubs are matched via arguments, you may have multiple stubs
# for the same method name.

use Moose;
use namespace::autoclean;

use Carp qw( croak );
use MooseX::Types::Moose qw( ArrayRef );
use Scalar::Util qw( blessed );

with 'Test::Magpie::Role::MethodCall';

# croak() messages should not trace back to Magpie modules
# to facilitate debugging of user test scripts
our @CARP_NOT = qw( Test::Magpie::Mock );

has '_executions' => (
    isa     => ArrayRef,
    is      => 'ro',
    default => sub { [] },
);

# returns(@return_values)
#
# Pushes a stub method that will return the given values to the end of the
# execution queue.

# old names for returns() and dies() methods kept for backwards compatibility
*then_return = \&returns;
*then_die    = \&dies;

sub returns {
    my ($self, @return_values) = @_;

    push @{$self->_executions}, sub {
        return wantarray || @return_values > 1
            ? @return_values
            : $return_values[0];
    };
    return $self;
}

# dies($exception)
#
# Pushes a stub method that will throw C<$exception> when called to the end of
# the execution queue.

sub dies {
    my ($self, $exception) = @_;

    push @{$self->_executions}, sub {
        $exception->throw
            if blessed($exception) && $exception->can('throw');

        croak $exception;
    };
    return $self;
}

# Executes the next execution

sub execute {
    my ($self) = @_;
    my $executions = $self->_executions;

    # return undef by default
    return if @$executions == 0;

    # use the execution at the front of the queue and
    # shift it off the queue - unless it is the last one
    my $execution = @$executions > 1
        ? shift(@$executions)
        : $executions->[0];

    return $execution->();
}

__PACKAGE__->meta->make_immutable;
1;
