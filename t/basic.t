use strict;
use warnings;
use Test::Mockito qw( when mock verify );
use Test::More;

my $mock = mock();
print $mock->foo;

pass;
done_testing;

