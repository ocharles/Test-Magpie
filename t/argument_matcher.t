#!/usr/bin/perl -T
use strict;
use warnings;

use Test::More;
use Test::Fatal;

use MooseX::Types::Moose qw( Int );
use Scalar::Util 'reftype';

use constant ArgumentMatcher => 'Test::Magpie::ArgumentMatcher';

BEGIN { use_ok ArgumentMatcher, qw(anything custom_matcher hash set type) }

subtest 'anything' => sub {
    my $matcher = anything;
    isa_ok $matcher, ArgumentMatcher;
    is reftype $matcher, 'CODE',  'isa CODEREF';

    is_deeply [$matcher->(qw[arguments are ignored])], [], 'ignore args';
    is_deeply [$matcher->()], [], 'no args';
};

subtest 'custom_matcher' => sub {
    my $matcher = custom_matcher {ref($_) eq 'ARRAY'};
    isa_ok $matcher, ArgumentMatcher;
    is reftype $matcher, 'CODE',  'isa CODEREF';

    is_deeply [$matcher->([])], [], 'match';
    is $matcher->(123), undef, 'no match';
    is $matcher->(),    undef, 'no args';
};

subtest 'hash' => sub {
    my $matcher = hash(a => 1, b => 2, c => 3);
    isa_ok $matcher, ArgumentMatcher;
    is reftype $matcher, 'CODE',  'isa CODEREF';

    is_deeply [$matcher->(a => 1, b => 2, c => 3)], [], 'match exactly';
    is_deeply [$matcher->(c => 3, b => 2, a => 1)], [], 'match different order';
    is $matcher->(a => 1, b => 2),         undef, 'missing key';
    is $matcher->(a => 1, b => 2, d => 3), undef, 'different key';
    is $matcher->(a => 1, b => 2, c => 4), undef, 'different value';
    is $matcher->(),                       undef, 'no args';
};

subtest 'set' => sub {
    my $matcher = set(1, 1, 2, 3, 4, 5);
    isa_ok $matcher, ArgumentMatcher;
    is reftype $matcher, 'CODE',  'isa CODEREF';

    is_deeply [$matcher->(1, 1, 2, 3, 4, 5)], [], 'match exactly';
    is_deeply [$matcher->(1, 2, 3, 4, 5)],    [], 'match unique set';
    is_deeply [$matcher->(5, 4, 3, 2, 1)],    [], 'match different order';
    is $matcher->(1, 2, 3, 4, 5, 6), undef, 'more args';
    is $matcher->(1, 2, 3, 4),       undef, 'less args';
    is $matcher->(2, 3, 4, 5, 6),    undef, 'different args';
    is $matcher->(),                 undef, 'no args';
};

subtest 'type' => sub {
    my $matcher = type(Int);
    isa_ok $matcher, ArgumentMatcher;
    is reftype $matcher, 'CODE',  'isa CODEREF';

    is_deeply [$matcher->(234)],   [], 'match Int';
    is_deeply [$matcher->('234')], [], 'match Int (Str)';
    is $matcher->(234.14),  undef, 'no match - Num';
    is $matcher->('hello'), undef, 'no match - Str';
    is $matcher->([234]),   undef, 'no match - ArrayRef';
    is $matcher->(),        undef, 'no args';
};

done_testing(6);
