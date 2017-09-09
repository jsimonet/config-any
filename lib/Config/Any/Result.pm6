use v6;

class Config::Any::Result is export {
	has $.backend is required;
	has $.key is required;
	has $.value is required is rw;

	multi method Str {
		$!value
	}

	multi method gist {
		my $b = ~$.backend;
		my $k = ~$.key;
		my $v = $.value;
		"Config::Result.new(:backend($b), :key($k), :value($v))"
	}
}
