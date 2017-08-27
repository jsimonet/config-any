use v6.c;

role Config::Any::Backend::Reader {
	proto method get( Str:D $key ) { * }
}

role Config::Any::Backend::Writer {
	proto method set( Str:D $key, $value ) { * }
}

role Config::Any::Backend::Requirable {
	proto method require( Str:D $key ) returns Bool { * }

	# Optimisation
	# proto method require( Str:D $keys ) returns Bool { * }
}

class Config::Any::Backend { * }

class Config::Any::Backend::Memory is Config::Any::Backend
                     does Config::Any::Backend::Reader
                     does Config::Any::Backend::Writer
                     does Config::Any::Backend::Requirable {

	has %!data;

	method get( Str:D $key ) {
		%!data{$key};
	}

	method set( Str:D $key, $data ) {
		%!data{$key} = $data;
	}

	method require( Str:D $key ) {
		%!data{$key}:exists.so
	}
}
