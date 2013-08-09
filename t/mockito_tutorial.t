#!/usr/bin/perl -T
use strict;
use warnings;

use Test::Fatal;
use Test::More;

use MooseX::Types::Moose qw( Int );

use Test::Magpie;
use Test::Magpie::ArgumentMatcher qw( type custom_matcher );

subtest 'Lets verify some behaviour!' => sub {
    my $mocked_list = mock;

    $mocked_list->add('one');
    $mocked_list->clear;

    verify($mocked_list)->add('one');
    verify($mocked_list)->clear;
};

subtest 'How about some stubbing?' => sub {
    my $mocked_list = mock;

    stub($mocked_list)->get(0)->returns('first');
    stub($mocked_list)->get(1)->dies('Kaboom!');

    is($mocked_list->get(0) => 'first');
    ok(exception { $mocked_list->get(1) });
    is($mocked_list->get => undef);

    verify($mocked_list)->get(0);
};

subtest 'Argument matchers' => sub {
    my $mocked_list = mock;
    stub($mocked_list)->get(type(Int))->returns('element');
    stub($mocked_list)->get(custom_matcher { $_ eq 'hello' })->returns('Hi!');

    is($mocked_list->get(999) => 'element');
    is($mocked_list->get('hello') => 'Hi!');

    verify($mocked_list)->get(type(Int));
};

subtest 'Verifying the number of invocations' => sub {
    my $list = mock;

    $list->add($_) for qw( one two two three three three );

    verify($list)->add('one');
    verify($list, times => 1)->add('one');
    verify($list, times => 2)->add('two');
    verify($list, times => 3)->add('three');
    verify($list, times => 0)->add('never');

    verify($list, at_least => 1)->add('three');
    verify($list, at_most => 2)->add('two');
};

done_testing;
