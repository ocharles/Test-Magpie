use strict;
use warnings;
use Test::Magpie qw( when mock verify );
use Test::More;
use Test::Moose;

{
    package Role;
    use Moose::Role;
}

subtest 'Roles' => sub {
    my $mock = mock(
        with => 'Role'
    );
    does_ok($mock, 'Role');

    $mock->method;

};

done_testing;
