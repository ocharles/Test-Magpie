package Test::Mockito::Stub;
use Moose;

use List::AllUtils qw( all pairwise );
use MooseX::Types::Moose qw( ArrayRef );

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

sub execute {
    my $self = shift;
    return $self->next_return;
}

1;
