use v6;

class Config::Any::Result is export {
	has $.backend is required;
	has $.value is required;

	multi method Str {
		$!value
	}

	multi method gist {
		my $b = ~$.backend;
		my $v = $.value;
		"Config::Result.new(:backend($b), :value($v))"
	}
}
