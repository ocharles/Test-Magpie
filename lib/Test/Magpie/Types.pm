package Test::Magpie::Types;
use MooseX::Types -declare => [qw( Mock )];

class_type Mock, { class => 'Test::Magpie::Mock' };

1;
