[![Build Status](https://travis-ci.org/jsimonet/config-any.svg?branch=master)](https://travis-ci.org/jsimonet/config-any)
[![Build status](https://ci.appveyor.com/api/projects/status/kvd5vd1vg0q583nj/branch/master?svg=true)](https://ci.appveyor.com/project/jsimonet/config-any/branch/master)

# NAME

Config::Any - Manage configuration data from many sources (files, environment variables, databases, …).

# SYNOPSIS

```perl6
use Config::Any;
use Config::Backend::File::JSON;
use Config::Backend::Env;

my $config = Config::Any.new;

# Search in Env and then in File::JSON
$config.add( Config::Backend::Env.new );
$config.add( Config::Backend::File::JSON.new( file => '/full/path/to/file.json' ) );

$config.get( 'db.host' );
# Will return a Config::Result

$config.get-all( 'db.host' );
# Will return an array of Config::Result for each backend where the data is defined

my @config-data = $config.get-all( '*' );
# Will return an array of stored values
```

# DESCRIPTION

This module gives the possibility to retreive a configuration data from many sources (local or distant). If many sources are specified, they are checked in the order they are defined and the first result is returned.

# BACKENDS

A backend is a class used to load a configuration source (a file, a database, etc…), to get a value from it, and/or to set a new one.
It should inherit from Config::Backend to be usable with Config::Any.

A backend can be readable only, writable only or both.

## Config::Backend::Reader

Provide the get method.

```perl6
method get( Str:D $key ) {
	...
}
```

## Config::Backend::Writer

Provide the set method.

```perl6
multi method set( Str:D $key, $data ) {
	...
}

multi method set( Config::Any::Result $data ) {
	...
}
```

## Other syntax (TODO):

Use a hash syntax?
```perl6
my $result = $config{'key'}; # Or $config<key>
$result.update( 'newvalue' );
$config{'key'} = $result;
```

### Usage example:

```perl6
# Write the config value to the first writable backend.
Config.set( 'mysecondkey', 'second value' );

# Write the config value to the backend where the result were found
# If this backend is not writable, throw an error.
my $result = Config.get( 'mykey' );
$result.update( 'newfirstvalue' );
Config.set( $result );
```

## Example

```perl6
class Config::Any::Backend::Example
	is   Config::Any::Backend
	does Config::Any::Readable
	does Config::Any::Writable {

	method get( Str:D $key ) {
		return Example::get-some-value();
	}

	method set( Str:D $key, $data ) {
		Example::set-some-value( $key, $data );
	}
}
```

# METHODS

## Config::Any::get

```perl6
my $res = Config.get( 'key' );
```

Result will be:
```perl6
Config::Result.new( backend => 'Config::Any::Backend::Environment', value => '...' ),
```

## Config::Any::get-all

```perl6
my @res = Config.get-all( 'key' );
```

Result will be:
```perl6
@res = [
	Config::Result.new( backend => 'Config::Any::Backend::Environment', value => 'value1' ),
	Config::Result.new( backend => 'Config::Any::Backend::Database::SQL', value => 'value2' ),
]
```

## Config::Any::dump

dump fonctionnality could be a get-all extention: get-all( '\*' )

# Security

Some configuration should not be accessed everywhere (database passwords). Is it possible to detect caller?

  * Using acl

```perl6
use Config;
#            SRC           KEY         VALUE
Config::ACL( '*',          'db.*',    'reject' );
Config::ACL( 'My::Module', 'db.host', 'pass' );
```

```
'reject from "*" key "db.key"'
'access from "My::Module" to "db.host" option readonly'
```

# Key requirements

Throws an error if the key(s) cannot be found in backends.

```perl6
Config::Any.required-key( 'db.host' );
Config::Any.required-keys( 'db.host', 'db.user', 'db.password' );
```

## Schema validation

We can imagine to extend this system with a more generalised one which would allow
type verifications for example.

```perl6
Config::Any.validate(
	'database.username' => { :type(Str:D) }, # Checks if the value of 'username' is a Str:D
	'database.host' => { * ~~ /<URI>/}       # Checks if the host value matches the regex
);
```

# Exporting names into variables

```perl6
# JSON data example : { "database" : { "username" : "toto", "password" : "psw" } }
Config::Any.export();

# Configuration is available in current scope
note $database.username, $database.password;

# How to do with arrays? Do not export because un-named (exception)?
```

# Tree visibility

A module may need a key under a certain tree, like 'database.host, database.user, etc…'.

The configuration tree can be viewed as something like :

```YAML
- app1
  - database
    - host = 'hostname'
    - user = 'username'
```

It can be usefull to rename/present a subtree differently:
```YAML
  - database
    - host = 'hostname'
    - user = 'username'
```

```perl6
# Allows to modify the way a client module can see a data.
Config::Any.will-see( :module('CallerModule'), :from('/app1'), :to('/'));
```
