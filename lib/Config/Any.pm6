use v6.c;

use Config::Any::Backend;
use Config::Any::Result;

class Config::Any {
	has @!backends = (Config::Any::Backend::Memory.new); # Default backend

	=head1 get
	=para
		Search and return the value associated with the key $key.

	multi method get( Str:D $key ) is export {
		for @!backends -> $b {
			my $v = $b.get: $key;
			return Config::Any::Result.new( backend => $b, value => $v ) if $v;
		}
		return Any;
	}

	multi method get( *@keys where @keys.all ~~ Str:D ) {
		return map {
			self.get( $_ )
		}, @keys;
	}

	# TODO
	# Return all keys/values that can be found
	multi method get( '*' ) {
		...
	}

	multi method get-all( Str:D $key ) is export {
		return eager gather {
			for @!backends -> $b {
				with $b.get( $key ) -> $v {
					take Config::Any::Result.new( backend => $b, value => $v );
				}
			}
		};
	}

	multi method get-all( @keys where @keys.all ~~ Str:D ) {
		return map { self.get-all( $_ ) }, @keys;
	}

	# Return all keys/values that can be found
	multi method get-all( '*' ) {
		...
	}

	# Set the value in the first "writer" backend found
	# Returns a Config::Result with the backend where the value was stored
	multi method set( Str:D $key, $value ) {
		my $res;
		for @!backends -> $b {
			if $b ~~ Config::Any::Backend::Writer {
				$b.set( $key, $value );
				# dd $b, $value;
				$res = Config::Any::Result.new( :backend( $b ), :value( $value ) );
				last
			}
		}
		return $res;
	}

	multi method add( Config::Any::Backend:D $config ) {
		unshift @!backends, $config;
	}

	multi method add( Config::Any::Backend:U $configClass ) {
		unshift @!backends, $configClass.new;
	}

	# TODO: Seems to be bugged
	multi method add( Str:D $config-class-name ) {
		require "Config::Any::Backend::$config-class-name";
	}

	class X::Config::Any::RequiredKeyNotFound is Exception {
		has @.keys is required;

		multi method message {
			@.keys == 1
				?? "Required key ("~@!keys~") not found in any backend."
				!! "Required keys ("~@!keys~") not found in any backend.";
		}
	}

	method !search-required-key( $key ) {
		my $res = False;
		for @!backends -> $b {
			if $b ~~ Config::Any::Backend::Requirable {
				$res = $b.require( $key );
				last;
			}
		}
		return $res;
	}

	# Check if at least one result exists
	multi method required-key( Str:D $key ) {
		unless self!search-required-key( $key ) {
			# die "Required key($key) not found in any backend." unless $res;
			die X::Config::Any::RequiredKeyNotFound.new( :keys($key) );
		}
		return True;
	}

	multi method required-key( *@keys ) {
		my @found = grep { ! self!search-required-key( $_ ) }, flat @keys;
		die X::Config::Any::RequiredKeyNotFound.new( :keys(flat @found) ) if @found.elems > 0;
	}

	# Resolution order
	method ro {
		@!backends».join
	}
}
