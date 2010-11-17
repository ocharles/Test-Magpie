package Test::Mockito::Mock;
use Moose;
use namespace::autoclean;

use aliased 'Test::Mockito::Invocation';
use aliased 'Test::Mockito::Expectation';

use MooseX::Types::Moose qw( ArrayRef Int );
use Moose::Util qw( find_meta );
use Test::Builder;

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
    my $invocations = $meta->get_attribute('invocations')->get_value($self);
    my $invocation = Invocation->new(
        method_name => $method,
        arguments => \@_
    );

    push @$invocations, $invocation;
    return;
}

1;
