use strict;
use warnings;
use Test::Mockito qw( mock );
use Test::More;

my $mock = mock;

$mock->do_something;

pass;
done_testing;
