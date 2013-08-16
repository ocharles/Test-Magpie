package Test::Magpie::Role::HasMock;
# ABSTRACT: A role for objects that wrap around a mock
use Moose::Role;
use namespace::autoclean;

has 'mock' => (
    is => 'bare',
    required => 1
);

1;

=head1 INTERNAL

This class is internal, and not meant for use outside Magpie.

=attr mock

The mock object itself. No accessor is generated. Required.

=cut
