use v6.c;

=head1 Basic tests
=para
  Test with only one backend.

use Test;

plan 11;

use-ok 'Config::Any';
use Config::Any;
use Config::Any::Result;

# config any has at least one backend : memory which allows getting and setting values in-memory
my $config = Config::Any.new;

can-ok $config, 'get';
can-ok $config, 'get-all';
can-ok $config, 'set';

can-ok Config::Any, 'get';
can-ok Config::Any, 'get-all';
can-ok Config::Any, 'set';

# set and get should returns the same result in this case
# because the first and only backend set is Memory which is Reader and Writer.
subtest {
  my $result-of-set = $config.set( 'test', 'val1' );
  isa-ok $result-of-set, Config::Any::Result;
  isa-ok $result-of-set.backend, Config::Any::Backend::Memory;
  is $result-of-set.value, 'val1', 'Getting the correct value';
}, 'Testing result of Config::Any::set';

subtest {
  plan 4;
  my $result-of-get = $config.get( 'test' );
  isa-ok $result-of-get, Config::Any::Result;
  isa-ok $result-of-get.backend, Config::Any::Backend::Memory;
  is $result-of-get.value, 'val1', 'Getting the correct value';
  is $result-of-get.key, 'test', 'Getting the correct key';
}, 'Testing result of Config::Any::get';

# Get-all
subtest {
  plan 6;
  my @results = $config.get-all( 'test' );
  isa-ok @results, List;
  is @results.elems, 1, 'There is only one element in the list.';

  isa-ok @results[0], Config::Any::Result;
  isa-ok @results[0].backend, Config::Any::Backend::Memory;
  is @results[0].value, 'val1', 'Getting the correct value';
  is @results[0].key, 'test', 'Getting the correct key';
}, 'Testing result of Config::Any::get-all';

# Required key tests
subtest {
  lives-ok { $config.required-key('test') }, 'Required key is present.';
  dies-ok { $config.required-key('non-existant') }, 'Absent required key thows an exception';
  $config.set( 'key2', 'value2' );
  throws-like { $config.required-key( 'non-existant') }, X::Config::Any::RequiredKeyNotFound;

  lives-ok { $config.required-key( 'test', 'key2' ); }, 'Required keys "test" and "key2" are present.';
  throws-like { $config.required-key( 'test', 'non-existant') }, X::Config::Any::RequiredKeyNotFound;
  throws-like { $config.required-key( 'non-existant', 'test') }, X::Config::Any::RequiredKeyNotFound;
  throws-like { $config.required-key( 'non-existant', 'non-existant-2') }, X::Config::Any::RequiredKeyNotFound;
  {
    CATCH {
      when X::Config::Any::RequiredKeyNotFound {
        is-deeply $_.keys, ['non-existant', 'non-existant-2'], 'Exception instance has the good keys.';
      }
      default { flunk 'Not the right exception.'}
    };
    $config.required-key( 'non-existant', 'test', 'non-existant-2');
  };
}, 'Testing required keys.';
