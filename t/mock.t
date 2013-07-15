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
    ok $mock,              'mock()';
    isa_ok $mock, 'Bar';
    ok $mock->isa('Bar'),  'isa anything';
    ok $mock->does('Baz'), 'does anything';
    is ref($mock), Mock,   'no ref';
};

subtest 'mock(class)' => sub {
    my $mock = mock('Foo');
    ok $mock,             'mock(class)';
    is ref($mock), 'Foo', 'ref';

    like exception {mock($mock)},
        qr/^The argument for mock\(\) must be a string/,
        'arg exception';
};

done_testing(3);
