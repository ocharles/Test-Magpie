use strict;
use warnings;
use Test::Mockito qw( history mock );
use Test::More;

my $mock = mock;

$mock->do_something;
$mock->explode('rapidly');

diag(history($mock));

pass;
done_testing;
