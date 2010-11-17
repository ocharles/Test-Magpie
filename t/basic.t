use strict;
use warnings;
use Test::Mockito qw( when mock verify );
use Test::More;
use Test::Fatal;

subtest 'Basic' => sub {
    my $mock = mock();
    ok(!$mock->foo);
};

subtest 'Stubbing basic' => sub {
    my $mock = mock;
    when($mock)->foo->then_return('bar');
    is($mock->foo, 'bar');
};

subtest 'Exceptions' => sub {
    my $mock = mock;
    when($mock)->die->then_die('Oh no!');
    ok exception { $mock->die };
    ok !exception { $mock->something_else };
};

subtest 'Exceptions 2' => sub {
    my $dog = mock;
    when($dog)->bark->then_return('woof');
    when($dog)->meow->then_die('Who do you think I am?');

    ok exception { $dog->meow };
    is $dog->bark => 'woof';
};

subtest 'Argument matching' => sub {
    my $list = mock;
    when($list)->get(0)->then_return('first');
    when($list)->get(1)->then_return('second');
    is($list->get(0), 'first');
    is($list->get(1), 'second');
};

subtest 'consecutive' => sub {
    my $iterator = mock;
    when($iterator)
        ->next
            ->then_return(1)
            ->then_return(2)
            ->then_die('Out of numbers');

    is($iterator->next, 1);
    is($iterator->next, 2);
    ok exception { $iterator->next };
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
    verify($dummy, times => 3)->bar;
};

pass;
done_testing;

