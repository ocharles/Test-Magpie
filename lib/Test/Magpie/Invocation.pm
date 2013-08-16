package Test::Magpie::Invocation;
# ABSTRACT: Represents an invocation of a method

use Moose;
use namespace::autoclean;

with 'Test::Magpie::Role::MethodCall';

__PACKAGE__->meta->make_immutable;
1;

=head1 DESCRIPTION

An invocation of a method on a mock object

=attr arguments

Returns a list of all arguments passed to the method call.

=attr method_name

The name of the method invoked.

=cut
