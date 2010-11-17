package Test::Magpie::Spy;
use Moose;
use namespace::autoclean;

use aliased 'Test::Magpie::Invocation';

use List::AllUtils qw( first );
use Moose::Util qw( find_meta );
use Test::Builder;
use Test::Magpie::Util qw( extract_method_name );

with 'Test::Magpie::Role::HasMock';

has 'invocation_counter' => (
    default => sub {
        sub { @_ > 0 }
    },
    is => 'bare',
);

my $tb = Test::Builder->new;

sub BUILDARGS {
    my $self = shift;
    my %args = @_;

    if (my $times = delete $args{times}) {
        $args{invocation_counter} = sub { @_ == $times };
    }

    return \%args;
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $method = extract_method_name($AUTOLOAD);
    my $observe = Invocation->new(
        method_name => $method,
        arguments => \@_
    );

    my $meta = find_meta($self);
    my $mock = $meta->get_attribute('mock')->get_value($self);
    my $invocations = find_meta($mock)->get_attribute('invocations')
        ->get_value($mock);

    my @matches = grep { $_->satisfied_by($observe) } @$invocations;
    
    my $invocation_counter = $meta->get_attribute('invocation_counter')
        ->get_value($self);

    $tb->ok($invocation_counter->(@matches), 
        sprintf("%s was invoked the correct number of times",
            $observe->as_string));
}

1;
