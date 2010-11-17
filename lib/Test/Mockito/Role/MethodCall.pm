package Test::Mockito::Role::MethodCall;
use Moose::Role;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str );
use Devel::PartialDump;

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
    return
        $invocation->method_name eq $self->method_name &&
        @{[ $invocation->arguments ]} ~~ @{[ $self->arguments ]};
}

1;
