package Test::Magpie;
# ABSTRACT: Spy on objects to achieve test doubles (mock testing)
use strict;
use warnings;

use aliased 'Test::Magpie::Inspect';
use aliased 'Test::Magpie::Mock';
use aliased 'Test::Magpie::Spy';
use aliased 'Test::Magpie::When';

use Moose::Util qw( find_meta ensure_all_roles );
use MooseX::Params::Validate;
use Test::Magpie::Types Mock => { -as => 'MockType' };

use Sub::Exporter -setup => {
    exports => [qw(
        inspect mock when verify
        at_least at_most
    )]
};

sub verify {
    my $mock = shift;
    return Spy->new(mock => $mock, @_);
}

sub mock {
    return Mock->new if @_ == 0;

    my $blessed;
    $blessed = shift if @_ % 2;
    my %opts = @_;
    $opts{blessed} = $blessed if defined $blessed;

    return Mock->new(\%opts);
}

sub when {
    my ($mock) = pos_validated_list(\@_,
        { isa => MockType }
    );
    return When->new(mock => $mock);
}

sub inspect {
    my ($mock) = pos_validated_list(\@_,
        { isa => MockType }
    );
    return Inspect->new(mock => $mock);
}

sub at_least {
    my $n = shift;
    return sub { @_ >= $n }
}

sub at_most {
    my $n = shift;
    return sub { @_ <= $n }
}

1;

=head1 SYNOPSIS

    use Test::Magpie qw( mock verify when );

    my $baker = mock;
    my $bakery = Bakery->new( bakers => [ $baker ] );
    my $bread = $bakery->buy_loaf( amount => 2, type => 'white' );
    verify($baker, times => 2)->bake_loaf('white');

=head1 DESCRIPTION

Test::Magpie is a test double framework heavily inspired by the Mockito
framework for Java, and also the Python-Mockito project. In Mockito, you "spy"
on objects for their behaviour, rather than being upfront about what should
happen. I find this approach to be significantly more flexible and easier to
work with than mocking systems like EasyMock, so I created a Perl
implementation.

C<Test::Magpie> doesn't do much, but it does export the main routines that you
use to interact with the framework.

=head2 Mock objects

Mock objects, represented by L<Test::Magpie::Mock> objects, are objects that
pretend to be everything you could ever want them to be. A mock object can have
any method called on it, does every roles, and isa subclass of any superclass.
This allows you to easily throw a mock object around it will be treated as
though it was a real object.

=head2 Methods and stubbing

Any method can be called on a mock object, and it will be logged as an
invocation. Most often though, clients will be more interested in the result of
calling a method with some arguments, so you may stub methods in order to
specify what happens at execution.

=head2 Verification

After calling your concrete code (the code under test) you may want to check
that the code did operate correctly on the mock. To do this, you can use
verifications to make sure code was called, with correct parameters and the
correct amount of times.

=head2 Argument matching

Magpie gives you some helpful methods to validate arguments passed in to calls.
You can check equality between arguments, or consume a general type of argument,
or consume multiple arguments. See L<Test::Magpie::ArgumentMatcher> for the
juicy details.

=func mock([$blessed])

Construct a new instance of a mock object.

C<$blessed> is an optional argument to set the type that the mock object is
blessed into. This value will be returned when C<ref()> is called on the object.

=func verify($mock, [%options])

Begin the verification process on a mock. Takes a mock object, and gives back a
L<Test::Magpie::Spy>. You don't really need to be concerned about the API of
this object, you should treat it as the same as the mock object itself. Any
method calls trigger verification that the given method was passed, and will
fail if the method was never invoked on the mock object.

C<%options> contains a few nice options to help make verification easier:

=over 4

=item times

Makes sure that the given method was called C<times> times. This may either be
an integer, or it could be a bit more general, and specified using
L<Test::Magpie/at_least> or L<Test::Magpie/at_most>

=back

=func when($mock)

Specify a stub method for C<$mock>.

Returns an object that should be treated the same as C<$mock> (that is, having
all the same methods), but a method call stores a stub method in the mock class,
rather than an invocation. After specifying the method you wish to stub, you
will be working with a L<Test::Magpie::Stub>, and you should consult that
documentation for how to fully specify the stub.

=func inspect($mock)

Inspect method invocations on a mock object. See L<Test::Magpie::Inspect> for
more information.

=func at_least(Int $n)

Verify that a method was invoked at least C<$n> times

=func at_most(Int $n)

Verify that a method was invoked at most C<$n> times

=cut
