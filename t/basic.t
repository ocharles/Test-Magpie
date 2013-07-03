use strict;
use warnings;
use Test::Magpie qw( when mock verify );
use Test::More;
use Test::Fatal;

subtest 'Basic' => sub {
    my $mock = mock();
    ok(!$mock->foo);
};

subtest 'Types' => sub {
    my $mock = mock('Foo');
    is ref($mock), 'Foo';
    ok $mock->isa('Bar');
    ok $mock->does('Baz');
};

subtest 'spying' => sub {
    my $spy = mock;
    $spy->method_call;
    verify($spy)->method_call;
};

subtest 'verification count' => sub {
    my $dummy = mock;
    $dummy->foo for (1,2);
    $dummy->bar for (1,2);
    verify($dummy, times => 2)->foo;
    verify($dummy, times => 2)->bar;
};

pass;
done_testing;

