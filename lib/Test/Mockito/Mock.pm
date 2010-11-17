package Test::Mockito::Mock;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef );
use Moose::Util qw( find_meta );

has 'invocations' => (
    isa => ArrayRef,
    is => 'bare',
    traits => [ 'Array' ],
    default => sub { [] }
);

our $AUTOLOAD;

sub AUTOLOAD {
    my $method = $AUTOLOAD;
    my $self = shift;
    my $meta = find_meta($self);

    push @{ $meta->get_attribute('invocations')->get_value($self) },
        [ $method, \@_ ];
}

1;
