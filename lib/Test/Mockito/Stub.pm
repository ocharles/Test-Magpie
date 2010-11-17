package Test::Mockito::Stub;
use Moose;

use List::AllUtils qw( all pairwise );
use MooseX::Types::Moose qw( ArrayRef );
use Scalar::Util qw( blessed );

with 'Test::Mockito::Role::MethodCall';

has 'executions' => (
    isa => ArrayRef,
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        _store_execution => 'push',
        _next_execution => 'shift'
    }
);

sub execute {
    my $self = shift;
    return $self->_next_execution->();
}

sub matches_invocation {
    my ($self, $invocation) = @_;
    return
        $invocation->method_name eq $self->method_name &&
        @{[ $invocation->arguments ]} ~~ @{[ $self->arguments ]};
}

sub then_return {
    my $self = shift;
    my $ret = shift;
    $self->_store_execution(sub {
        return $ret;
    });
    return $self;
}

sub then_die {
    my $self = shift;
    my $exception = shift;
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

1;
