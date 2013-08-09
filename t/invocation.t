#!/usr/bin/perl -T
use strict;
use warnings;

use Test::More tests => 8;

BEGIN { use_ok 'Test::Magpie' }

use aliased 'Test::Magpie::Invocation';

use Test::Magpie::ArgumentMatcher qw( anything );
use Test::Magpie::Util qw( get_attribute_value );

my $mock = mock;
ok ! $mock->foo(123, bar => 456), 'mock method invoked';

my $invocation = get_attribute_value($mock, 'calls')->[-1];
isa_ok $invocation, Invocation;

is $invocation->name, 'foo',                       'name';
is_deeply [$invocation->args], [123, 'bar', 456],  'args';
is $invocation->as_string, 'foo(123, "bar", 456)', 'as_string';

is Invocation->new(
    name => 'method',
    args => [anything],
)->as_string, 'method(anything())', 'as_string with overloaded args';

subtest 'satisfied_by' => sub {
    ok $invocation->satisfied_by( Invocation->new(
        name => 'foo',
        args => [123, 'bar', 456]
    ) ), 'exact match';

    ok ! $invocation->satisfied_by(
        Invocation->new(
            name => 'bar',
            args => [123, 'bar', 456],
        )
    ), 'different name';

    ok ! $invocation->satisfied_by(
        Invocation->new(name => 'foo')
    ), 'no args';

    ok ! $invocation->satisfied_by(
        Invocation->new(
            name => 'foo',
            args => [123, 'bar'],
        )
    ), 'less args';

    ok ! $invocation->satisfied_by(
        Invocation->new(
            name => 'foo',
            args => [123, 'bar', 123],
        )
    ), 'different args';

    ok ! $invocation->satisfied_by(
        Invocation->new(
            name => 'foo',
            args => [123, 'bar', 456, 123]
        )
    ), 'more args';

    SKIP: {
        skip 'Not allowed: Invocation objects with argument matchers', 1;
        fail;
    }
};
