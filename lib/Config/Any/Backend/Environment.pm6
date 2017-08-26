use v6;

use Config::Any::Backend;

=head1 Config::Any::Backend::Environment

=para
Read the environment variables.
The environment is read-only, so only do Config::Any::Backend::Reader role.

class Config::Any::Backend::Environment
	is Config::Any::Backend
	does Config::Any::Backend::Reader {

	=head2 get
	=para Reurns the value associated to $key.

	method get( Str:D $key ) {
		%*ENV{$key}
	}

}
