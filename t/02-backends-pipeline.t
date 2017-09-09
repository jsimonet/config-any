use v6.c;

use Test;
plan 9;

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
ok Config::Any.add( Config::Any::Backend::Test ), 'Can add a class on undifined class';
ok Config::Any.add( Config::Any::Backend::Test.new ), 'Can add a class on undifined class';

# todo 'Add a backend by name.';
# ok $config.add( 'Test' );

dies-ok { $config.add( Int ) }, 'Cannot add a class wich does not inherits from Config::Any::Backend.';
dies-ok { $config.add( Int.new ) }, 'Cannot add an instance of a class wich does not inherits from Config::Any::Backend.';

my @resolutionOrder = $config.ro;
is @resolutionOrder.elems, 5, 'There is 3 backends.'; # Two previously added, plus one default 'Memory'

cmp-ok @resolutionOrder[0], '~~', /'Config::Any::Backend::Test'/, 'First backend is a Test';
cmp-ok @resolutionOrder[1], '~~', /'Config::Any::Backend::Test'/, 'Second backend is a Test';


=head2 Testing pipeline

class ReaderBackend is Config::Any::Backend does Config::Any::Backend::Reader {
  has %.data;
  method get(Str:D $key) { %!data{$key} }
}

class WriterBackend is Config::Any::Backend does Config::Any::Backend::Writer {
  has %.data;
  method get(Str:D $key) { %!data{$key} }
  method set(Str:D $key, $value) { %!data{$key} = $value }
}
