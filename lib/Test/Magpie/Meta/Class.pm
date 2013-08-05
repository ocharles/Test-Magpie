package Test::Magpie::Meta::Class;
# ABSTRACT: Metaclass for mocks
# A metaclass that pretends that its instances consume any role.

use Moose;
use namespace::autoclean;

extends 'Moose::Meta::Class';

override 'does_role' => sub { 1 };

__PACKAGE__->meta->make_immutable;
1;
