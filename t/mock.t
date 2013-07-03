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

done_testing(3);
