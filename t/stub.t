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

my $mock  = mock;
my $stubs = get_attribute_value($mock, 'stubs');

subtest 'stub()' => sub {
    my $stubber = stub($mock);
    isa_ok $stubber, 'Test::Magpie::Stubber';

    like exception { stub() },
        qr/^stub\(\) must be given a mock object/,
        'no arg';
    like exception { stub('string') },
        qr/^stub\(\) must be given a mock object/,
        'invalid arg';
};

subtest 'stub->invoked' => sub {
    my @args = ([], [123, bar => 456]);

    for (@args) {
        my $stub = stub($mock)->foo(@$_);
        isa_ok $stub, Stub;
        is $stubs->{foo}[0], $stub,  'stored at front of queue';

        is $stub->name, 'foo',       'name';
        is_deeply [$stub->args], $_, 'args';
    }
};

subtest 'returns(scalar)' => sub {
    my $stub = stub($mock)->foo->returns('bar');
    isa_ok $stub, Stub;

    is $mock->foo, 'bar', 'returns (scalar context)';
    is_deeply [$mock->foo], ['bar'], 'returns (array context)';
};

subtest 'returns(array)' => sub {
    my $stub = stub($mock)->foo->returns(qw[ bar baz ]);
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

subtest 'dies' => sub {
    my $dog = mock;
    my $stub = stub($dog)->meow;
    is $stub
        ->dies( 'dunno how' )
        ->dies( NonThrowable->new )
        ->dies( Exception::Tiny->new(
              message => 'my exception',
              file => __FILE__,
              line => __LINE__),
          ), $stub, 'chainable';

    my $exception = exception { $dog->meow };
    like $exception, qr/^dunno how/, 'died';
    like $exception, qr/stub\.t/, 'error traces back to this script';

    like exception { $dog->meow }, qr/^died/, 'died (blessed, cannot throw)';
    like exception { $dog->meow }, qr/^my exception/, 'exception';
};

subtest 'consecutive' => sub {
    my $iterator = mock;
    stub($iterator)
        ->next
            ->returns(1)
            ->returns(2)
            ->dies('Out of numbers');

    is $iterator->next, 1;
    is $iterator->next, 2;
    like exception { $iterator->next }, qr/^Out of numbers/;
    ok exception { $iterator->next }, 'last execution persists';
};

subtest 'argument matching' => sub {
    my $list = mock;
    stub($list)->get(0)->returns('first');
    stub($list)->get(1)->returns('second');
    stub($list)->get()->dies('no index given');

    ok ! $list->set(0, '1st'), 'no such method';
    ok ! $list->get(0, 1),     'extra args';

    is $list->get(0), 'first', 'exact match';
    is $list->get(1), 'second';
    like exception { $list->get() }, qr/^no index given/, 'no args';

    stub($list)->get(anything)->dies('index out of bounds');
    like exception { $list->get(-1) }, qr/index out of bounds/,
        'argument matcher';
};
