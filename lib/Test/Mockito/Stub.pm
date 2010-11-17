package Test::Mockito::Stub;
use Moose;

use List::AllUtils qw( all pairwise );
use MooseX::Types::Moose qw( ArrayRef );
use Scalar::Util qw( blessed );

with 'Test::Mockito::Role::MethodCall';

has 'returns' => (
    isa => ArrayRef,
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        then_return => 'push',
        next_return => 'shift'
    }
);

has 'exceptions' => (
    isa => ArrayRef,
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        then_die => 'push',
        next_exception => 'shift'
    }
);

sub execute {
    my $self = shift;
    if (my $exception = $self->next_exception) {
        if (blessed($exception) && $exception->can('throw')) {
            $exception->throw;
        }
        else {
            die $exception;
        }
    }
    return $self->next_return;
}

sub matches_invocation {
    my ($self, $invocation) = @_;
    return
        $invocation->method_name eq $self->method_name &&
        @{[ $invocation->arguments ]} ~~ @{[ $self->arguments ]};
 }


1;
