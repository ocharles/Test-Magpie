package Test::Magpie::Meta::Class;
# ABSTRACT: Metaclass for mocks
use Moose;
use namespace::autoclean;

extends 'Moose::Meta::Class';

override 'does_role' => sub { 1 };

__PACKAGE__->meta->make_immutable;
1;

=head1 DESCRIPTION

A metaclass that pretends that all instances consume every role.

=head1 INTERNAL

This metaclass is internal and not meant for use outside Magpie

=cut

