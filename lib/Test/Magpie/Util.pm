package Test::Magpie::Util;
# ABSTRACT: Internal utility functions for Test::Magpie

use strict;
use warnings;

# smartmatch dependencies
use 5.010;
use experimental qw( smartmatch );

use Exporter qw( import );
use Scalar::Util qw( blessed looks_like_number refaddr );
use Moose::Util qw( find_meta );

our @EXPORT_OK = qw(
    extract_method_name
    get_attribute_value
    has_caller_package
    match
);

=func extract_method_name

    $method_name = extract_method_name($full_method_name)

From a fully qualified method name such as Foo::Bar::baz, will return
just the method name (in this example, baz).

=cut

sub extract_method_name {
    my ($method_name) = @_;
    $method_name =~ s/.*:://;
    return $method_name;
}

=func get_attribute_value

    $value = get_attribute_value($object, $attr_name)

Gets value of Moose attributes that have no accessors by accessing the class'
underlying meta-object.

=cut

sub get_attribute_value {
    my ($object, $attribute) = @_;

    return find_meta($object)
        ->find_attribute_by_name($attribute)
        ->get_value($object);
}

=func has_caller_package

    $bool = has_caller_package($package_name)

Returns whether the given C<$package> is in the current call stack.

=cut

sub has_caller_package {
    my $package= shift;

    my $level = 1;
    while (my ($caller) = caller $level++) {
        return 1 if $caller eq $package;
    }
    return;
}

=func match

    $bool = match($a, $b)

Match 2 values for equality.

=cut

sub match {
    my ($a, $b) = @_;

    # This function uses smart matching, but we need to limit the scenarios
    # in which it is used because of its quirks.

    # ref types must match
    return if ref($a) ne ref($b);

    # objects match only if they are the same object
    if (blessed($a) || ref($a) eq 'CODE') {
        return refaddr($a) == refaddr($b);
    }

    # don't smartmatch on arrays because it recurses
    # which leads to the same quirks that we want to avoid
    if (ref($a) eq 'ARRAY') {
        return if $#{$a} != $#{$b};

        # recurse to handle nested structures
        foreach (0 .. $#{$a}) {
            return if !match( $a->[$_], $b->[$_] );
        }
        return 1;
    }

    # smartmatch only matches hash keys
    # but we want to match the values too
    if (ref($a) eq 'HASH') {
        return unless $a ~~ $b;

        foreach (keys %$a) {
            return if !match( $a->{$_}, $b->{$_} );
        }
        return 1;
    }

    # avoid smartmatch doing number matches on strings
    # e.g. '5x' ~~ 5 is true
    return if looks_like_number($a) xor looks_like_number($b);

    return $a ~~ $b;
}

1;
