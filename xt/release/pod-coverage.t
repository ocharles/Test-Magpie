#!perl

use Test::More;

eval "use Test::Pod::Coverage 1.08";
plan skip_all => "Test::Pod::Coverage 1.08 required for testing POD coverage"
  if $@;

eval "use Pod::Coverage::TrustPod";
plan skip_all => "Pod::Coverage::TrustPod required for testing POD coverage"
  if $@;

# test public modules only
plan tests => 4;
pod_coverage_ok($_, {coverage_class => 'Pod::Coverage::TrustPod'})
    foreach qw(
        Test::Magpie
        Test::Magpie::ArgumentMatcher
        Test::Magpie::Invocation
        Test::Magpie::Mock
    );
