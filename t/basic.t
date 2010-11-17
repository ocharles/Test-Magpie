use strict;
use warnings;
use Test::Mockito qw( when mock verify );
use Test::More;

subtest 'Basic' => sub {
    my $mock = mock();
    ok(!$mock->foo);
};

subtest 'Stubbing basic' => sub {
    my $mock = mock;
    when($mock)->foo->then_return('bar');
    is($mock->foo, 'bar');
};

pass;
done_testing;

