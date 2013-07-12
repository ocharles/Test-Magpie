#!/usr/bin/perl -T
use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::Builder::Tester;

BEGIN { use_ok 'Test::Magpie', qw(mock verify at_least at_most) }

use Test::Magpie::Util qw( get_attribute_value );

my $mock = mock;

subtest 'verify()' => sub {
    my $spy = verify($mock);
    isa_ok $spy, 'Test::Magpie::Spy';

    is get_attribute_value($spy, 'mock'), $mock, 'has mock';

    like exception { verify },
        qr/^verify\(\) must be given a mock object/,
        'no arg';
    like exception { verify('string') },
        qr/^verify\(\) must be given a mock object/,
        'invalid arg';
};

subtest 'times default' => sub {
    $mock->once;
    verify($mock)->once;
};

# currently Test::Builder::Test (0.98) does not work with subtests
# subtest 'times' => sub {
{
    like exception { verify($mock, times => 'string') },
        qr/^option \'times\' must be a number/, 'invalid times';

    $mock->twice() for 1..2;
    verify($mock, times => 2)->twice();

    test_out('not ok 1 - twice() was invoked the correct number of times');
    test_fail(+1);
    verify($mock, times => 1)->twice;
    test_test('times not equal');
}

# subtest 'at_least' => sub {
{
    like exception { verify($mock, at_least => 'string') },
        qr/^option \'at_least\' must be a number/, 'invalid at_least';

    verify($mock, at_least => 1)->once;

    test_out('not ok 1 - once() was invoked the correct number of times');
    test_fail(+1);
    verify($mock, at_least => 2)->once;
    test_test('at_least not reached');
}

# subtest 'at_most' => sub {
{
    like exception { verify($mock, at_most => 'string') },
        qr/^option \'at_most\' must be a number/, 'invalid at_most';

    verify($mock, at_most => 2)->twice;

    test_out('not ok 1 - twice() was invoked the correct number of times');
    test_fail(+1);
    verify($mock, at_most => 1)->twice;
    test_test('at_most exceeded');
}

done_testing(9);
