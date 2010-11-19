package Test::Magpie::Inspect;
# ABSTRACT: Inspect invocations of methods on mocks
use Moose;
use namespace::autoclean;

use aliased 'Test::Magpie::Invocation';

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Map );

use List::AllUtils qw( first );
use Moose::Util qw( find_meta );
use Test::Magpie::Util qw( extract_method_name );

with 'Test::Magpie::Role::HasMock';

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $method_name = extract_method_name($AUTOLOAD);

    my $meta = find_meta($self);
    my $mock = $meta->find_attribute_by_name('mock')->get_value($self);
    my $invocations = find_meta($mock)->find_attribute_by_name('invocations')
        ->get_value($mock);

    my $inspect = Invocation->new(
        method_name => $method_name,
        arguments => \@_
    );

    return first { $inspect->satisfied_by($_) } @$invocations;
}

1;

=head1 SYNOPSIS

    my $mock = mock;
    $mock->something({ deep => { structure => [] }};
    my $invocation = inspect($mock)->something(anything);
    ok(defined $invocation, 'something was called');
    is_deeply(($invocation->arguments)[0],
        { deep => { structure => [] }})

=head1 DESCRIPTION

Inspecting a mock objects allows you to write slightly clearer tests than having
a complex verification call. L<Test::Magpie/inspect> gives back an object of
this class that, like other functions, has the same API as your mock object.

When a method is called, we see if any invocation matches it's name and argument
specification (inspectors can use argument matchers), and if so - return that
invocation as a L<Test::Magpie::Invocation>. Otherwise, C<undef> is returned.

=cut
