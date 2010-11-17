package Test::Mockito;
use strict;
use warnings;

use aliased 'Test::Mockito::Mock';
use aliased 'Test::Mockito::Spy';
use aliased 'Test::Mockito::When';

use Data::Dumper;
use Moose::Util qw( find_meta );

use Sub::Exporter -setup => {
    exports => [qw( mock when verify )]
};

sub verify {
    my $mock = shift;
    return Spy->new(mock => $mock, @_);
}

sub mock {
    return Mock->new;
}

sub when {
    my $mock = shift;
    return When->new(mock => $mock);
}

1;
