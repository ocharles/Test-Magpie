package Test::Mockito;
use strict;
use warnings;

use aliased 'Test::Mockito::Mock';

use Data::Dumper;
use Moose::Util qw( find_meta );

use Sub::Exporter -setup => {
    exports => [qw( history mock verify )]
};

sub history {
    my $mock = shift;
    join("\n", map { Dumper($_) } @{
        find_meta($mock)->get_attribute('invocations')->get_value($mock)
    });
}

sub verify {
    my $mock = shift;
    find_meta($mock)->get_attribute('state')->set_value($mock => 2);
    return $mock;
}

sub mock {
    return Mock->new;
}

1;
