package Test::Magpie::Mock;
# ABSTRACT: Mock objects

=head1 SYNOPSIS

    # create a mock object
    my $mock = mock(); # from Test::Magpie
    my $mock_with_class = mock('AnyRef');

    # mock objects pretend to be anything you want them to be
    $true = $mock->isa('AnyClass');
    $true = $mock->does('AnyRole');
    $true = $mock->DOES('AnyRole');
    $ref  = ref($mock_with_class); # AnyRef

    # call any method with any arguments
    $method_ref = $mock->can('any_method');
    $mock->any_method(@arguments);

=head1 DESCRIPTION

Mock objects are the objects you pass around as if they were real objects. They
do not have a defined API; any method may be called. Additionally, you can
create stubs to specify responses (return values or exceptions) to method
calls.

A mock objects records every method called on it along with their arguments.
These records may then be used for verifying that the correct interactions
occured.

=cut

use Moose -metaclass => 'Test::Magpie::Meta::Class';
use namespace::autoclean;

use aliased 'Test::Magpie::Invocation';
use aliased 'Test::Magpie::Stub';

use Test::Magpie::Util qw(
    extract_method_name
    get_attribute_value
    has_caller_package
);

use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Map );
use UNIVERSAL::ref;

our $AUTOLOAD;

=attr class

The name of the class that the object is pretending to be blessed into. Calling
C<ref()> on the mock object will return this class name.

=cut

has 'class' => (
    isa => Str,
    reader => 'ref',
    default => __PACKAGE__,
);

=attr calls

An array reference containing a record of all methods called on this mock.
These are used for verification and inspection.

This attribute is internal, and not publically accessible.

=cut

has 'calls' => (
    isa => ArrayRef[Invocation],
    is => 'bare',
    default => sub { [] }
);

=attr stubs

Contains all of the methods stubbed for this mock. It maps the method name to
an array of stubs. Stubs are matched against invocation arguments to determine
which stub to dispatch to.

This attribute is internal, and not publically accessible.

=cut

has 'stubs' => (
    isa => Map[ Str, ArrayRef[Stub] ],
    is => 'bare',
    default => sub { {} }
);

sub AUTOLOAD {
    my $self = shift;
    my $method_name = extract_method_name($AUTOLOAD);

    # record the method call for verification
    my $method_call = Invocation->new(
        name => $method_name,
        args => \@_,
    );

    my $calls = get_attribute_value($self, 'calls');
    my $stubs = get_attribute_value($self, 'stubs');

    push @$calls, $method_call;

    # find a stub to return a response
    if (defined $stubs->{$method_name}) {
        foreach my $stub ( @{$stubs->{$method_name}} ) {
            return $stub->execute
                if $stub->satisfied_by($method_call);
        }
    }
    return;
}

=method isa

Always returns true. It allows the mock object to C<isa()> any class that
is required.

    $true = $mock->isa('AnyClass');

=cut

sub isa {
    my ($self, $package) = @_;
    return if (
        has_caller_package('UNIVERSAL::ref') ||
        $package =~ /^Class::MOP::*/
    );
    return 1;
}

=method does

Always returns true. It allows the mock object to C<does()> any role that
is required.

    $true = $mock->does('AnyRole');
    $true = $mock->DOES('AnyRole');

=cut

sub does {
    return if has_caller_package('UNIVERSAL::ref');
    return 1;
}

=method ref

Returns the object's C<class> attribute value. This also works if you call
C<ref()> as a function instead of a method.

    $mock  = mock('AnyRef');
    $class = $mock->ref;  # or ref($mock)

If the object's C<class> attribute has not been set, then it will fallback to
returning the name of this class.

=cut

=method can

Always returns a reference to the C<AUTOLOAD()> method. It allows the mock
object to C<can()> do any method that is required.

    $method_ref = $mock->can('any_method');

=cut

sub can {
    my ($self, $method_name) = @_;
    return sub {
        $AUTOLOAD = $method_name;
        goto &AUTOLOAD;
    };
}

__PACKAGE__->meta->make_immutable;
1;
