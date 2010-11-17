package Test::Magpie::When;
use Moose;
use namespace::autoclean;

use aliased 'Test::Magpie::Stub';
use Moose::Util qw( find_meta );
use Test::Magpie::Mock qw( add_stub );
use Test::Magpie::Util qw( extract_method_name );

with 'Test::Magpie::Role::HasMock';

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $method_name = $AUTOLOAD;
    my $mock = find_meta($self)->get_attribute('mock')->get_value($self);
    
    my $stub = Stub->new(
        method_name => extract_method_name($method_name),
        arguments => \@_
    );

    add_stub($mock, $stub);
    return $stub;
}

1;
