use v6.c;

use Test;
plan 8;

use Config::Any;

class ReaderBackend is Config::Any::Backend does Config::Any::Backend::Reader {
  has %.data;
  method get(Str:D $key) { %!data{$key} }
}

class WriterBackend is Config::Any::Backend does Config::Any::Backend::Writer {
  has %.data;
  method get(Str:D $key) { %!data{$key} }
  method set(Str:D $key, $value) { %!data{$key} = $value }
}

my $config = Config::Any.new;
$config.add( ReaderBackend.new( data => (:color('red'), :foo('bar')) ) );
$config.add( WriterBackend.new( data => (:color('yellow')) ) );

my $result-set = $config.set( 'color', 'magenta' );
cmp-ok $result-set, '~~', Config::Any::Result;
is $result-set, 'magenta';

my @results = $config.get-all( 'color' );
is @results.elems, 2;
cmp-ok @results[0], '~~', Config::Any::Result;
is @results[0], 'red';
cmp-ok @results[1], '~~', Config::Any::Result;
is @results[1], 'magenta';

@results[1].value = 'newcolor';

$config.set( @results[1] );

subtest {
	my $results2 = $config.get-all( 'color' );

	is @results.elems, 2;
	cmp-ok @results[0], '~~', Config::Any::Result;
	is @results[0], 'red';
	cmp-ok @results[1], '~~', Config::Any::Result;
	is @results[1], 'newcolor';
}, 'Tests setting a new value from a result, should be saved in the backend it comes from.';
