use v6.c;

use Config::Any::Backend;
use Config::Any::Result;

class Config::Any {
	my Config::Any $instance;
	has @!backends = (Config::Any::Backend::Memory.new); # Default backend

	method new {
		unless $instance {
			$instance = Config::Any.bless;
		}
		return $instance;
	}

	sub get-caller-package {
		my $caller;
		for Backtrace.new -> $b {
			if $b.code ~~ Routine {
				if $b.code.package.^name ~~ /^ 'Config::Any' | ^ 'Backtrace' / {
					next;
				}
				$caller = $b.code.package.^name;
				last;
			}
		}
		$caller //= '';
	}

	=head1 get
	=para
		Search and return the value associated with the key $key.

	multi method get( Config::Any:D: Str:D $key ) {
		my $caller = get-caller-package;
		my $real-key = '.'~$key;
		if $caller && ( %!tree-view{$caller}:exists ) {
			# note "orig key : $key";
			if %!tree-view{$caller}{'to'}:exists {
				my $to = %!tree-view{$caller}{'to'}~'.';
				my $from = %!tree-view{$caller}{'from'}~'.';
				# note "$to  $from";
				$real-key ~~ s/^$to/$from/;
			}
			# note "key change : $key";
		}

		# Remove the leading dot
		$real-key ~~ s/^\.//;

		for @!backends -> $b {
			my $v = $b.get: $real-key;
			return Config::Any::Result.new( backend => $b, :$key, value => $v ) if $v;
		}
		return Nil;
	}

	multi method get( Config::Any:U: $key ) {
		return self.new.get( $key );
	}

	multi method get( Config::Any:D: *@keys where @keys.all ~~ Str:D ) {
		return map {
			self.get( $_ )
		}, @keys;
	}

	multi method get( Config::Any:U:  *@keys where @keys.all ~~ Str:D ) {
		return self.new.get( @keys );
	}

	# TODO
	# Return all keys/values that can be found
	multi method get( '*' ) {
		...
	}

	multi method get-all( Str:D $key ) {
		return eager gather {
			for @!backends -> $b {
				with $b.get( $key ) -> $v {
					take Config::Any::Result.new( backend => $b, :$key, value => $v );
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
	multi method set( Config::Any:D: Str:D $key, $value ) {
		my $res;
		for @!backends -> $b {
			if $b ~~ Config::Any::Backend::Writer {
				$b.set( $key, $value );
				# dd $b, $value;
				$res = Config::Any::Result.new( :backend( $b ), :$key, :value( $value ) );
				last
			}
		}
		return $res;
	}

	multi method set( Config::Any:D: Config::Any::Result:D $result ) {
		my $res = False;
		for @!backends -> $b {
			if $b ~~ $result.backend {
				$b.set( $result.key, $result.value );
				# dd $b, $value;
				$res = $result;
				last
			}
		}
		return $res;
	}

	multi method add( Config::Any:D: Config::Any::Backend:D $backend ) {
		# Throw an exception on error
		@!backends.splice( * - 1, 0, $backend );
		True
	}
	multi method add( Config::Any:U: Config::Any::Backend:D $backend ) {
		return self.new.add( $backend );
	}

	multi method add( Config::Any:D: Config::Any::Backend:U $backendClass ) {
		# Throw an exception on error
		@!backends.splice( * - 1, 0, $backendClass.new );
		True
	}
	multi method add( Config::Any:U: Config::Any::Backend:U $backendClass ) {
		return self.new.add( $backendClass );
	}

	# TODO: Seems to be bugged
	multi method add( Str:D $config-class-name ) {
		...;
		# TODO
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

	has %tree-view;

	multi method will-see( Str:D :$module is required, :$from! is required, :$to = '' ) {
		%!tree-view{$module} = { :$from, :$to };
		return True;
	}
}
