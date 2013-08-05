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

use MooseX::Types::Moose qw( ArrayRef );
use Scalar::Util qw( blessed );

with 'Test::Magpie::Role::MethodCall';

has 'executions' => (
    isa => ArrayRef,
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        _store_execution => 'push',
        _next_execution => 'shift',
        _has_executions => 'count',
    }
);

# then_return(@return_values)
#
# Pushes a stub method that will return the given values to the end of the
# execution queue.

sub then_return {
    my $self = shift;
    my @ret  = @_;
    $self->_store_execution(sub {
        return wantarray ? (@ret) : $ret[0];
    });
    return $self;
}

# then_die($exception)
#
# Pushes a stub method that will throw C<$exception> when called to the end of
# the execution queue.

sub then_die {
    my ($self, $exception) = @_;

    $self->_store_execution(sub {
        if (blessed($exception) && $exception->can('throw')) {
            $exception->throw;
        }
        else {
            die $exception;
        }
    });
    return $self;
}

# Executes the next execution, if possible

sub execute {
    my ($self) = @_;
    #$self->_has_executions || confess "Stub has no more executions";

    return ( $self->_next_execution )->();
}

__PACKAGE__->meta->make_immutable;
1;
