package Test::Magpie::Types;
# ABSTRACT: Type constraints used by Magpie

use MooseX::Types -declare => [qw( Mock NumRange )];

use MooseX::Types::Moose qw( Num );
use MooseX::Types::Structured qw( Tuple );

subtype NumRange, as Tuple[Num, Num];

class_type Mock, { class => 'Test::Magpie::Mock' };

1;

=head1 DESCRIPTION

This class is mostly meant for internal purposes.

=type Mock

Verifies that an object is a Magpie mock

=cut
