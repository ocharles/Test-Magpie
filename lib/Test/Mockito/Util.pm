package Test::Mockito::Util;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw( extract_method_name )],
};

sub extract_method_name {
    my $name = shift;
    my ($method) = $name =~ qr/:([^:]+)$/;
    return $method;
}

1;
