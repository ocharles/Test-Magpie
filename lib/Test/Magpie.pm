package Test::Magpie;
# ABSTRACT: Spy on objcets to achieve test doubles (mock testing)
use strict;
use warnings;

use aliased 'Test::Magpie::Mock';
use aliased 'Test::Magpie::Spy';
use aliased 'Test::Magpie::When';

use Moose::Util qw( find_meta ensure_all_roles );

use Sub::Exporter -setup => {
    exports => [qw( mock when verify )]
};

sub verify {
    my $mock = shift;
    return Spy->new(mock => $mock, @_);
}

sub mock {
    my %opts = @_;
    my $mock = Mock->new;
    if (my $with = $opts{with}) {
        my @roles = ref($with) ? @$with : ($with);
        for my $role (@roles) {
            my $meta = find_meta($role);
            for my $method ($meta->get_required_method_list) {
                $mock->meta->add_method($method => sub {
                    shift;
                    $mock->_mock_handler($method->name, @_);
                });
            }
            ensure_all_roles($mock, $role);
        }
    }
    return $mock;
}

sub when {
    my $mock = shift;
    return When->new(mock => $mock);
}

1;
