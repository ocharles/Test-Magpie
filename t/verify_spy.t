#!/usr/bin/perl -T
use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::Builder::Tester;

BEGIN { use_ok 'Test::Magpie', qw(mock verify at_least at_most) }

use Test::Magpie::Util qw( get_attribute_value );

my $file = __FILE__;
my $err;

my $mock = mock;
$mock->once;
$mock->twice() for 1..2;

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

test_out 'ok 1 - once() was called once';
verify($mock, times => 1, name => 'once() was called once')->once;
test_test 'name';

test_out 'ok 1 - once() was invoked the correct number of times';
verify($mock)->once;
test_test 'times default';

# currently Test::Builder::Test (0.98) does not work with subtests
# subtest 'times' => sub {
{
    like exception { verify($mock, times => 'string') },
        qr/^'times' option must be a number/, 'invalid times';

    test_out 'ok 1 - twice() was invoked the correct number of times';
    verify($mock, times => 2)->twice();
    test_test 'times equal';

    my $name = 'twice() was invoked the correct number of times';
    my $line = __LINE__ + 9;
    test_out "not ok 1 - $name";
    chomp($err = <<ERR);
#   Failed test '$name'
#   at $file line $line.
#          got: 2
#     expected: 1
ERR
    test_err $err;
    verify($mock, times => 1)->twice;
    test_test 'times not equal';
}

# subtest 'at_least' => sub {
{
    like exception { verify($mock, at_least => 'string') },
        qr/^'at_least' option must be a number/, 'invalid at_least';

    my $name = 'once() was invoked the correct number of times';
    test_out "ok 1 - $name";
    verify($mock, at_least => 1)->once;
    test_test 'at_least';

    my $line = __LINE__ + 10;
    test_out "not ok 1 - $name";
    chomp($err = <<ERR);
#   Failed test '$name'
#   at $file line $line.
#     '1'
#         >=
#     '2'
ERR
    test_err $err;
    verify($mock, at_least => 2)->once;
    test_test 'at_least not reached';
}

# subtest 'at_least()' => sub {
{
    like exception { verify($mock, times => at_least('string')) },
        qr/at_least\(\) must be given a number/, 'invalid at_least()';

    my $name = 'once() was invoked the correct number of times';
    test_out "ok 1 - $name";
    verify($mock, times => at_least(1))->once;
    test_test 'at_least()';

    my $line = __LINE__ + 10;
    test_out "not ok 1 - $name";
    chomp($err = <<ERR);
#   Failed test '$name'
#   at $file line $line.
#     '1'
#         >=
#     '2'
ERR
    test_err $err;
    verify($mock, times => at_least(2))->once;
    test_test( title => 'at_least() not reached', skip_err => 1 );
}

# subtest 'at_most' => sub {
{
    like exception { verify($mock, at_most => 'string') },
        qr/^'at_most' option must be a number/, 'invalid at_most';

    test_out 'ok 1 - twice() was invoked the correct number of times';
    verify($mock, at_most => 2)->twice;
    test_test 'at_most';

    test_out 'ok 1 - twice() was invoked the correct number of times';
    verify($mock, times => at_most(2))->twice;
    test_test 'at_most()';

    my $name = 'twice() was invoked the correct number of times';
    my $line = __LINE__ + 10;
    test_out "not ok 1 - $name";
    chomp($err = <<ERR);
#   Failed test '$name'
#   at $file line $line.
#     '2'
#         <=
#     '1'
ERR
    test_err $err;
    verify($mock, at_most => 1)->twice;
    test_test 'at_most exceeded';
}

# subtest 'at_most()' => sub {
{
    like exception { verify($mock, times => at_most('string')) },
        qr/^at_most\(\) must be given a number/, 'invalid at_most()';

    test_out 'ok 1 - twice() was invoked the correct number of times';
    verify($mock, times => at_most(2))->twice;
    test_test 'at_most()';

    my $name = 'twice() was invoked the correct number of times';
    my $line = __LINE__ + 10;
    test_out "not ok 1 - $name";
    chomp($err = <<ERR);
#   Failed test '$name'
#   at $file line $line.
#     '2'
#         <=
#     '1'
ERR
    test_err $err;
    verify($mock, times => at_most(1))->twice;
    test_test( title => 'at_most exceeded', skip_err => 1 );
}

like exception {
    verify($mock, times => 2, at_least => 2, at_most => 2)->twice
}, qr/^You can set only one of these options:/, 'multiple options';

done_testing(21);
