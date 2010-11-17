package Test::Mockito::Mock;
use Moose;

use Sub::Exporter -setup => {
    exports => [qw( add_stub )],
};

use aliased 'Test::Mockito::Invocation';

use Test::Mockito::Util qw( extract_method_name );
use List::AllUtils qw( first );
use MooseX::Types::Moose qw( ArrayRef Int Object Str );
use MooseX::Types::Structured qw( Map );
use Moose::Util qw( find_meta );
use Test::Builder;

has 'invocations' => (
    isa => ArrayRef,
    is => 'bare',
    default => sub { [] }
);

has 'stubs' => (
    isa => Map[Str, Object],
    is => 'bare',
    default => sub { {} }
);

our $AUTOLOAD;

sub AUTOLOAD {
    my $method = $AUTOLOAD;
    my $self = shift;
    my $meta = find_meta($self);
    my $invocations = $meta->get_attribute('invocations')->get_value($self);
    my $invocation = Invocation->new(
        method_name => extract_method_name($method),
        arguments => \@_
    );

    push @$invocations, $invocation;

    if(my $stubs = $meta->get_attribute('stubs')->get_value($self)->{
        $invocation->method_name
    }) {
        
        my $stub = first { $_->matches_invocation($invocation) } @$stubs;
        return unless $stub;
        $stub->execute;
    }
}

sub add_stub {
    my ($self, $stub) = @_;
    my $meta = find_meta($self);
    my $stubs = $meta->get_attribute('stubs')->get_value($self);
    my $method = $stub->method_name;
    $stubs->{$method} ||= [];
    push @{ $stubs->{$method} }, $stub;
}

1;
