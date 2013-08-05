package Test::Magpie::Role::HasMock;
# ABSTRACT: A role for objects that wrap around a mock

use Moose::Role;
use namespace::autoclean;

has 'mock' => (
    is => 'bare',
    required => 1
);

1;
