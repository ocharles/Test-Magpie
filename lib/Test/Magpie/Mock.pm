package Test::Magpie::Mock;
# ABSTRACT: A mock object
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

has 'class' => (
    isa => Str,
    reader => 'ref',
    default => __PACKAGE__,
);

has 'invocations' => (
    isa => ArrayRef[Invocation],
    is => 'bare',
    default => sub { [] }
);

has 'stubs' => (
    isa => Map[ Str, ArrayRef[Stub] ],
    is => 'bare',
    default => sub { {} }
);

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $method_name = extract_method_name($AUTOLOAD);

    # record the method invocation for verification
    my $invocation  = Invocation->new(
        method_name => $method_name,
        arguments   => \@_,
    );

    my $invocations = get_attribute_value($self, 'invocations');
    push @$invocations, $invocation;

    # find a stub to return a response
    if (
        my $stubs = get_attribute_value($self, 'stubs')->{ $method_name }
    ) {
        for my $stub (@$stubs) {
            return $stub->execute if (
                $stub->satisfied_by($invocation) &&
                $stub->_has_executions
            );
        }
        return;
    }
}

sub does {
    return if has_caller_package('UNIVERSAL::ref');
    return 1;
}

sub isa {
    my ($self, $package) = @_;
    return if (
        has_caller_package('UNIVERSAL::ref') ||
        $package =~ /^Class::MOP::*/
    );
    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

=head1 DESCRIPTION

Mock objects are the objects you pass around as if they were real objects. They
do not have a defined API; any method call is valid. A mock on its own is in
record mode - method calls and arguments will be saved. You can switch
temporarily to stub and verification mode with C<when> and C<verify> in
L<Test::Magpie>, respectively.

=attr class

This attribute is the name of the class that the object is pretending to be
blessed into. This is only needed if you call C<ref()> on the object and want
it to return a particular type.

=attr stubs

This attribute is internal, and not publically accessible.

Returns a map of method name to stub array references. Stubs are matched against
invocation arguments to determine which stub to dispatch to.

=attr invocations

This attribute is internal, and not publically accessible.

Returns an array reference of all method invocations on this mock.

=method isa $class

Forced to return true for any package

=method does $role

Forced to return true for any role

=method ref

Returns the value of the object's C<class> attribute. This also works if you
call C<ref()> as a function instead of a method.

=cut
