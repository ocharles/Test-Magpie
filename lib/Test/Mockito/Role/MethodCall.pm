package Test::Mockito::Role::MethodCall;
use Moose::Role;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str );

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
    return $self->method_name . '(' . join(", ", $self->arguments) . ')';
}

1;
