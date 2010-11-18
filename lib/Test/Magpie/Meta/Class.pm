package Test::Magpie::Meta::Class;
use Moose;
use namespace::autoclean;

extends 'Moose::Meta::Class';

override 'does_role' => sub { 1 };

1;
