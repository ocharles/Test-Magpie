package Test::Mockito::Mock;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Int );
use Moose::Util qw( find_meta );

our $STATE_RECORD = 1;
our $STATE_VERIFY = 2;

has 'invocations' => (
    isa => ArrayRef,
    is => 'bare',
    traits => [ 'Array' ],
    default => sub { [] }
);

has 'state' => (
    isa => Int,
    is => 'bare',
    default => $STATE_RECORD
);

our $AUTOLOAD;

sub AUTOLOAD {
    my $method = $AUTOLOAD;
    my $self = shift;
    my $meta = find_meta($self);
    my $state = $meta->get_attribute('state')->get_value($self);
    my $invocations = $meta->get_attribute('invocations')->get_value($self);

    if ($state == $STATE_RECORD) {
        push @$invocations, [ $method, \@_ ];
    }
    elsif ($state == $STATE_VERIFY) {
        my $top = shift(@$invocations);
        die "Verification error"
            unless $top && $top->[0] eq $method;
    }
}

1;
