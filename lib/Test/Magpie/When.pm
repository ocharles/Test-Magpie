package Test::Magpie::When;
# ABSTRACT: The process of stubbing a mock method call
use Moose;
use namespace::autoclean;

use aliased 'Test::Magpie::Stub';
use Test::Magpie::Util qw( extract_method_name get_attribute_value );

with 'Test::Magpie::Role::HasMock';

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $method_name = extract_method_name($AUTOLOAD);

    my $stub = Stub->new(
        method_name => $method_name,
        arguments => \@_
    );

    my $mock  = get_attribute_value($self, 'mock');
    my $stubs = get_attribute_value($mock, 'stubs');

    push @{ $stubs->{$method_name} }, $stub;

    return $stub;
}

1;

=head1 DESCRIPTION

A mock object in stub mode to declare a stubbed method. You generate this by
calling C<when> in L<Test::Magpie> with a mock object.

This object has the same API as the mock object - any method call will start the
creation of a L<Test::Magpie::Stub>, which can be modified to tailor the stub
call. You are probably more interested in that documentation.

=cut
