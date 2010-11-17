package Test::Mockito;
use strict;
use warnings;

use aliased 'Test::Mockito::Mock';

use Sub::Exporter -setup => {
    exports => [qw( mock )]
};

sub mock {
    return Mock->new;
}

1;
