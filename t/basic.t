use strict;
use warnings;
use Test::Mockito qw( history mock verify );
use Test::More;

my $mock = mock;

$mock->do_something;
$mock->explode('rapidly');

verify($mock);
$mock->do_something;
$mock->explode;
$mock->boom;

pass;
done_testing;
