use v6.c;

=head1 Basic tests

use Test;

# plan 2;

use-ok 'Config::Any';
use Config::Any;
use Config::Any::Result;

# config any has at least one backend : memory which allows getting and setting values in-memory
my $config = Config::Any.new;

can-ok $config, 'set';

# set and get should returns the same result in this case
# because the first and only backend set is Memory which is Reader and Writer.
subtest {
  my $result-of-set = $config.set( 'test', 'val1' );
  isa-ok $result-of-set, Config::Any::Result;
  isa-ok $result-of-set.backend, Config::Any::Backend::Memory;
  is $result-of-set.value, 'val1', 'Getting the correct value';
}, 'Testing result of Config::Any::set';

subtest {
  my $result-of-get = $config.get( 'test' );
  isa-ok $result-of-get, Config::Any::Result;
  isa-ok $result-of-get.backend, Config::Any::Backend::Memory;
  is $result-of-get.value, 'val1', 'Getting the correct value';
}, 'Testing result of Config::Any::get';

# Get-all
subtest {
  my @results = $config.get-all( 'test' );
  isa-ok @results, List;
  is @results.elems, 1, 'There is only one element in the list.';

  isa-ok @results[0], Config::Any::Result;
  isa-ok @results[0].backend, Config::Any::Backend::Memory;
  is @results[0].value, 'val1', 'Getting the correct value';
}, 'Testing result of Config::Any::get-all';

# Required key tests
subtest {
  lives-ok { $config.required-key('test') }, 'Required key is present.';
  dies-ok { $config.required-key('non-existant') }, 'Absent required key thows an exception';
  $config.set( 'key2', 'value2' );
  lives-ok { $config.required-key( 'test', 'key2' ); }, 'Required keys "test" and "key2" are present.';
}, 'Testing required keys.';

done-testing;
