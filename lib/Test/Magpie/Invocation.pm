package Test::Magpie::Invocation;
# ABSTRACT: Represents an invocation of a method
use Moose;

with 'Test::Magpie::Role::MethodCall';

1;

=head1 DESCRIPTION

An invocation of a method on a mock object

=attr arguments

Returns a list of all arguments passed to the method call.

=attr method_name

The name of the method invoked;

=cut

