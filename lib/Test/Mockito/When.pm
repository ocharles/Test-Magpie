package Test::Mockito::When;
use Moose;
use namespace::autoclean;

use aliased 'Test::Mockito::Stub';
use Moose::Util qw( find_meta );
use Test::Mockito::Mock qw( add_stub );

has 'mock' => (
    is => 'bare',
    required => 1
);

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $method_name = $AUTOLOAD;
    my $mock = find_meta($self)->get_attribute('mock')->get_value($self);
    
    my $stub = Stub->new(
        method_name => $method_name,
    );

    add_stub($mock, $stub);
    return $stub;
}

1;
