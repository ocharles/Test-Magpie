#!/usr/bin/perl -T
use strict;
use warnings;

use Test::More tests => 8;
use Test::Fatal;

BEGIN { use_ok 'Test::Magpie' }

use aliased 'Test::Magpie::Invocation';
use Exception::Tiny;
use Test::Magpie::Util qw( get_attribute_value );
use Test::Magpie::ArgumentMatcher qw( anything );

use constant Stub => 'Test::Magpie::Stub';

my $mock = mock;
my $stubs = get_attribute_value($mock, 'stubs');

subtest 'when()' => sub {
    my $when = when($mock);
    isa_ok $when, 'Test::Magpie::When';

    like exception { when() },
        qr/^when\(\) must be given a mock object/,
        'no arg';
    like exception { when('string') },
        qr/^when\(\) must be given a mock object/,
        'invalid arg';
};

subtest 'when->invoked' => sub {
    my @args = ([], [123, bar => 456]);

    for (@args) {
        my $stub = when($mock)->foo(@$_);
        isa_ok $stub, Stub;
        is $stubs->{foo}[0], $stub,       'stored at front of queue';

        is $stub->method_name, 'foo',     'method_name';
        is_deeply [$stub->arguments], $_, 'arguments';
    }
};

subtest 'then_return(scalar)' => sub {
    my $stub = when($mock)->foo->then_return('bar');
    isa_ok $stub, Stub;

    is $mock->foo, 'bar', 'returns (scalar context)';
    is_deeply [$mock->foo], ['bar'], 'returns (array context)';
};

subtest 'then_return(array)' => sub {
    my $stub = when($mock)->foo->then_return(qw[ bar baz ]);
    isa_ok $stub, Stub;

    is $mock->foo, 2, 'returns (scalar context)';
    is_deeply [$mock->foo], [qw( bar baz )], 'returns (array context)';
};

{
    package NonThrowable;
    use overload '""' => \&message;
    sub new { bless [], $_[0] }
    sub message {'died'}
}

subtest 'then_die' => sub {
    my $dog = mock;
    my $stub = when($dog)->meow;
    is $stub
        ->then_die( 'dunno how' )
        ->then_die( NonThrowable->new )
        ->then_die( Exception::Tiny->new(
              message => 'my exception',
              file => __FILE__,
              line => __LINE__),
          ), $stub, 'chainable';

    my $exception = exception { $dog->meow };
    like $exception, qr/^dunno how/, 'died';
    like $exception, qr/when_stub\.t/, 'error traces back to this script';

    like exception { $dog->meow }, qr/^died/, 'died (blessed, cannot throw)';
    like exception { $dog->meow }, qr/^my exception/, 'exception';
};

subtest 'consecutive' => sub {
    my $iterator = mock;
    when($iterator)
        ->next
            ->then_return(1)
            ->then_return(2)
            ->then_die('Out of numbers');

    is $iterator->next, 1;
    is $iterator->next, 2;
    like exception { $iterator->next }, qr/^Out of numbers/;
    ok exception { $iterator->next }, 'last execution persists';
};

subtest 'argument matching' => sub {
    my $list = mock;
    when($list)->get(0)->then_return('first');
    when($list)->get(1)->then_return('second');
    when($list)->get()->then_die('no index given');

    ok ! $list->set(0, '1st'), 'no such method';
    ok ! $list->get(0, 1),     'extra args';

    is $list->get(0), 'first', 'exact match';
    is $list->get(1), 'second';
    like exception { $list->get() }, qr/^no index given/, 'no args';

    when($list)->get(anything)->then_die('index out of bounds');
    like exception { $list->get(-1) }, qr/index out of bounds/,
        'argument matcher';
};
