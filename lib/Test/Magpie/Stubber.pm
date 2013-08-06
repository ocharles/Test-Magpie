package Test::Magpie::Stubber;
# ABSTRACT: Create methods stubs for mock objects

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
        arguments   => \@_,
    );

    my $mock  = get_attribute_value($self, 'mock');
    my $stubs = get_attribute_value($mock, 'stubs');

    # add new stub to front of queue so that it takes precedence
    # over existing stubs that would satisfy the same invocations
    unshift @{ $stubs->{$method_name} }, $stub;

    return $stub;
}

__PACKAGE__->meta->make_immutable;
1;
