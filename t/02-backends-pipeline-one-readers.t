use v6.c;

use Test;
plan 2;

use Config::Any;

class ReaderBackend is Config::Any::Backend does Config::Any::Backend::Reader {
  has %.data;
  method get(Str:D $key) { %!data{$key} }
}

my $config = Config::Any.new;
$config.add( ReaderBackend.new: :data( :color('red'), :lang('Perl 6') ) );

is $config.get('lang'), 'Perl 6', 'Getting a key from the first backend.';
is $config.get('non-existant'), Nil, 'Getting a non existant key returns Nil.';
