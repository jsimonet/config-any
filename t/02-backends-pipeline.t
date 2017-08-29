use v6.c;

use Test;
plan 10;

use Config::Any;
use Config::Any::Backend;

=head1 Tests pipelines.
=para Tests Config::Any with multiple backends.

=head2 Testing addition of backends.
  A backend should inhorits from Config::Any::Backend.

my $config = Config::Any.new;

class Config::Any::Backend::Test is Config::Any::Backend {}

ok $config.add( Config::Any::Backend::Test ),     'Can add a class wich inherits from Config::Any::Backend.';
ok $config.add( Config::Any::Backend::Test.new ), 'Can add an instance of a class inheriting from Config::Any::Backend.';

# todo 'Add a backend by name.';
# ok $config.add( 'Test' );

dies-ok { $config.add( Int ) }, 'Cannot add a class wich does not inherits from Config::Any::Backend.';
dies-ok { $config.add( Int.new ) }, 'Cannot add an instance of a class wich does not inherits from Config::Any::Backend.';

my @resolutionOrder = $config.ro;
is @resolutionOrder.elems, 3, 'There is 3 backends.'; # Two previously added, plus one default 'Memory'

cmp-ok @resolutionOrder[0], '~~', /'Config::Any::Backend::Test'/, 'First backend is a Test';
cmp-ok @resolutionOrder[1], '~~', /'Config::Any::Backend::Test'/, 'Second backend is a Test';


=head2 Testing pipeline

class ReaderBackend is Config::Any::Backend does Config::Any::Backend::Reader {
  has %.data;
  method get(Str:D $key) { %!data{$key} }
}

subtest {
  my $config = Config::Any.new;
  $config.add( ReaderBackend.new: :data( :color('red'), :lang('Perl 6') ) );

  plan 2;
  is $config.get('lang'), 'Perl 6', 'Getting a key from the first backend.';
  is $config.get('non-existant'), Nil, 'Getting a non existant key returns Nil.';
}, 'Getting values with only one Reader.';


subtest {
  my $config = Config::Any.new;
  $config.add( ReaderBackend.new: :data( :color('red'), :lang('Perl 6') ) );
  $config.add( ReaderBackend.new: :data( :animal('dog'), :lang('Perl 5') ) );

  plan 7;
  todo 'Backend is «unshifted», so bad response returned.';
  is $config.get('lang'), 'Perl 6', 'Getting a key from the first backend.';
  is $config.get('animal'), 'dog', 'Getting a key from the second backend.';
  is $config.get('non-existant'), Nil, 'Getting a non existant key returns Nil.';

  my @results = $config.get-all( 'lang' );
  todo '', 2;
  is @results[0], Config::Any::Result;
  is @results[0].value, 'Perl 6';

  todo '', 2;
  is @results[1], Config::Any::Result;
  is @results[1].value, 'Perl 5';
}, 'Getting values with two Readers.';

subtest {
  plan 0;

}, 'Mixing Reader and Writer backends.';
