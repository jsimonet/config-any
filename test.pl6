use v6.c;

use lib 'lib';

use Config::Any;
#use Config::Backend::Database::SQL ( 'mysql:host=test;db=testdb' );
#dd Config.get( 'testkey' );

class Config::Any::Backend::Database::SQL
	is Config::Any::Backend
	does Config::Any::Backend::Reader
	does Config::Any::Backend::Writer {

	has %!data = 'key1' => 'val1', 'key2' => 'val2';

	method get( Str:D $key ) {
		%!data{$key}
	}

	method set( Str:D $key, $value ) {
		%!data{$key} = $value;
	}
}

use Config::Any::Backend::Environment;
# use Config::Any::Backend::Test;

# my $b = Config::Any::Backend::Database::SQL.new( dsn => 'truc' );
# dd $b.^methods;
# $b.set( 'key1', 'value' );
my $config = Config::Any.new;

# bugged
# Config::Any.add( 'Database::SQL' ); # Prevent using: use Config::Any::Backend::Database

$config.add( Config::Any::Backend::Environment );
# $config.add( Config::Any::Backend::Test.new );
$config.add( Config::Any::Backend::Database::SQL );

say "resolution order : \t", $config.ro;

#say "get key1: \t", $config.get( 'key1' );
say $config.get-all( 'key1' );
say $config.get-all( <key1 key2> );

# say "setting :\t ", $config.set( 'newkey1', 'setted value' );

# say "get newkey1 \t", $config.get( 'newkey1' );
# say "get-all newkey1 \t", $config.get-all( 'newkey1' );
# say "get( array ) : ", $config.get( [ 'key1', 'key2' ] );
# say "get( list ) : ", $config.get( ( 'key1', 'key2' ) );
# say "get( key, key ) : ", $config.get( 'key1', 'key2' );

# say $config.required-key( 'key1' );
# say $config.required-key( 'key3', 'key2' );
# TODO
# Config::ACL
# Use configuration from a module with defined backends from main

$config.set( 'app1.db.host', 'houstval' );
$config.set( 'app1.db.user', 'userval' );
$config.will-see( :module<Foo>, :from<app1> );
# say $config.get( 'db.host' );
$config.will-see( :module<Bar>, :from<app1.db> );
$config.will-see( :module<Bob>, :from<app1..db> );

# Should we use / instead of . ?
# .will-see( :from</app1/db>, :to</> );
# .get( '/host' );

note "\n\n\n";

dd class Foo {
	method foo {
		Config::Any.get( 'db.host' );
	}
}.foo;

dd class Bar {
	method bar {
		Config::Any.get( 'host' );
	}
}.bar;
dd class Bob {
	method bar {
		Config::Any.get( 'host' );
	}
}.bar;
