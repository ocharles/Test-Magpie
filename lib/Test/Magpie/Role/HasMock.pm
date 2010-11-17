package Test::Magpie::Role::HasMock;
use Moose::Role;
use namespace::autoclean;

has 'mock' => (
    is => 'bare',
    required => 1
);

1;
