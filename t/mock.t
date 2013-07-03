#!/usr/bin/perl -T
use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN { use_ok 'Test::Magpie', qw(mock when) }

use Test::Magpie::ArgumentMatcher qw( anything );

use constant Mock => 'Test::Magpie::Mock';

subtest 'mock()' => sub {
    my $mock = mock;
    ok $mock,               'mock()';
    isa_ok $mock, 'Bar';
    ok $mock->isa('Bar'),   'isa anything';
    ok $mock->does('Baz'),  'does anything';
    is $mock->class, Mock,  'no class';
    isnt ref($mock), 'Foo', 'no ref';
};

subtest 'mock(class)' => sub {
    my $mock = mock('Foo');
    ok $mock,               'mock(class)';
    is $mock->class, 'Foo', 'class';
    is ref($mock),   'Foo', 'ref';

    like exception {mock($mock)},
        qr/^The argument for mock\(\) must be a string/,
        'arg exception';
};

subtest 'invoke method with no stub' => sub {
    my $mock = mock;

    my @invocations = (
        ['foo', []],
        ['foo', [123]],
    );
    my $invocations = find_meta($mock)->find_attribute_by_name('invocations')
        ->get_value($mock);

    my $i = 0;
    foreach (@invocations) {
        my ($method, $args) = @$_;

        ok ! $mock->$method(@$args), 'invoked';

        is scalar @$invocations, $i + 1, 'invocation recorded';
        isa_ok $invocations->[$i], 'Test::Magpie::Invocation';
        is $invocations->[$i]->method_name, $method, 'method_name';
        is_deeply [$invocations->[$i]->arguments], $args, 'arguments';
        $i++;
    }
};

subtest 'invoke method with stubs' => sub {
    my $mock = mock;

    # generate the stubs
    when($mock)->foo->then_die('stub1');
    when($mock)->foo(123, 456)->then_die('stub2');
    when($mock)->foo(123)->then_return('stub3');
    when($mock)->foo(123)->then_return('stub4');
    when($mock)->foo(anything)->then_return('stub5');

    is $mock->foo(123), 'stub3', 'returned stub';
    is $mock->foo(123), 'stub4', 'returned next stub';
    is $mock->foo(123), 'stub5', 'returned stub with arg matcher';
    like exception {$mock->foo}, qr/^stub1/, 'returned previous stub';
};

done_testing(5);
