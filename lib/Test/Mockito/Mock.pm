package Test::Mockito::Mock;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Int );
use Moose::Util qw( find_meta );
use Test::Builder;

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

my $Test = Test::Builder->new();

sub AUTOLOAD {
    my $method = $AUTOLOAD;
    my $self = shift;
    my $meta = find_meta($self);
    my $state = $meta->get_attribute('state')->get_value($self);
    my $invocations = $meta->get_attribute('invocations')->get_value($self);
    my $invocation = [ $method, \@_ ];

    if ($state == $STATE_RECORD) {
        push @$invocations, $invocation;
    }
    elsif ($state == $STATE_VERIFY) {
        my $top = shift(@$invocations);
        unless ($top && $top->[0] eq $method) {
            $Test->ok(0, 'Verification failed');
            $Test->diag(
                sprintf "Expected:\t%s\nGot:\t\t%s",
                    (defined $top
                        ? $top->[0]
                        : '(no more calls)'),
                    $invocation->[0]
            );
        }
    }
}

1;
