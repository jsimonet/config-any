use v6.c;

use Test;
plan 8;

use Config::Any;

class ReaderBackend is Config::Any::Backend does Config::Any::Backend::Reader {
  has %.data;
  method get(Str:D $key) { %!data{$key} }
}

my $config = Config::Any.new;
$config.add( ReaderBackend.new: :data( :color('red'), :lang('Perl 6') ) );
$config.add( ReaderBackend.new: :data( :animal('dog'), :lang('Perl 5') ) );

is $config.get('lang'), 'Perl 6', 'Getting a key from the first backend.';
is $config.get('animal'), 'dog', 'Getting a key from the second backend.';
is $config.get('non-existant'), Nil, 'Getting a non existant key returns Nil.';

my @results = $config.get-all( 'lang' );
is @results.elems, 2;
cmp-ok @results[0], '~~', Config::Any::Result, 'The result from the first backend is a Config::Any::Result.';
is @results[0].value, 'Perl 6';

cmp-ok @results[1], '~~', Config::Any::Result;
is @results[1].value, 'Perl 5';
