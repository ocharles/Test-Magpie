package Test::Mockito::Mock;
use Moose;
use namespace::autoclean;

use aliased 'Test::Mockito::Invocation';
use aliased 'Test::Mockito::Expectation';

use MooseX::Types::Moose qw( ArrayRef Int );
use Moose::Util qw( find_meta );
use Test::Builder;

our $STATE_RECORD = 1;
our $STATE_VERIFY = 2;

has 'expectations' => (
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
    my $expectations = $meta->get_attribute('expectations')->get_value($self);
    my %args = (
        method_name => $method,
        arguments => \@_
    );

    if ($state == $STATE_RECORD) {
        my $expectation = Expectation->new(%args);
        push @$expectations, $expectation;
    }
    elsif ($state == $STATE_VERIFY) {
        my $expectation = shift(@$expectations);
        my $invocation = Invocation->new(%args);

        unless ($expectation && $expectation->satisfied_by($invocation)) {
            $Test->ok(0, 'Verification failed');
            $Test->diag(
                sprintf "Expected:\t%s\nGot:\t\t%s",
                    (defined $expectation
                        ? $expectation->as_string
                        : '(no more calls)'),
                    $invocation->as_string
            );
        }
    }
}

1;
