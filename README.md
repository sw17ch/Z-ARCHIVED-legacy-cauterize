# cauterize

A Ruby DSL for generating marshalable structured data easily compatable with
statically allocated C systems. Currently, it prefers simplicity and
predictability over speed.

# Why?

Basically, `malloc` is a huge pain when you only have 16K of RAM.

# Examples

There's currently a (single) example in this project. To run it, do this:

```
git clone git://github.com/sw17ch/cauterize.git
cd cauterize
bundle install
cd example
sh build.sh
```

If this completes without error, then you should find a bunch of generated code
in cauterize_output. Look at the structures and enumerations defined in the
`example_project.h` file. Also look at how the `Pack_*` and `Unpack_*`
functions are organized and named.

Once you've looked at this, take a look at `example_project.c`. This will show
you the exact mechanism used to package and unpackage different structures.

`cauterize.h` and `cauterize.c` are used as iterators over C buffers. They are
used to abstract the process of packaging and unpackaging different elements.

# Different Types

There are 6 fundamental classes of types in Cauterize. These types have several characteristics:

* They can be copied with `memcpy`.
* They do not attempt to cover the concept of indirection or pointers.
* They are simple.
* They cannot be defined recursively.

## Scalars

Scalars are any type that corresponds to a C scalar value. That is, something
that can be defined with the native types (`int`, `long`, `short`, etc). It is
highly recommended that these ONLY ever use values from `stdint.h`. This
ensures that the sizes of these scalars will be consistent across platforms.

Scalars can be defined simply by giving them a name that corresponds to a type
from `stdint.h`.

```ruby
scalar(:uint8_t)
scalar(:uint32_t)
```

## Enumerations

Enumerations correspond almost exactly to C enumerations. They are a list of
names. When appropriate, a specific scalar value may also be specified. If no
scalar is specified, enumerations will be represented in order from 0.

```ruby
enumeration(:color) do |e|
  e.value :red
  e.value :blue
  e.value :green
end

enumeration(:days_of_week) do |e|
  e.value :sunday, 100
  e.value :monday, 101
  e.value :tuesday, 102
  e.value :wednesday, 103
  e.value :thursday, 104
  e.value :friday, 105
  e.value :saturday, 106
end
```

## Fixed Arrays

Fixed arrays are arrays that only ever make sense when they are full. An
example of an array with this property is a MAC Address. MAC addresses are
always 6 bytes. Never more. Never less.

```ruby
fixed_array(:mac_address) do |a|
 a.array_type :uint8_t # the type held by the array
 a.array_size 6 # the number of elements in the array
end
```

## Variable Arrays

Variable Arrays are arrays that have a maximum length, but may not be entirely
utilized.

```ruby
# a way to represent some number of dates/times as 32-bit values
variable_array(:datetimes) do |a|
  a.size_type  :uint8_t # WILL BE DEPRECATED
  a.array_type :int32_t
  a.array_size 128
end

# a string, represented as `int_8`'s, with a maximum length of 32 bytes
variable_array(:string_32) do |a|
  a.size_type  :uint8_t # WILL BE DEPRECATED
  a.array_type :int8_t
  a.array_size 32
end
```

## Composites

Composites are very similar to C structures. They are collections of other
types. Each field has a name and may correspond to any other defined type.

```ruby
composite(:person) do |c|
  c.field :name, :string_32
  c.field :age, :uint8_t
  c.field :date_of_birth, :uint32_t
end
```

## Groups

Groups are similar to C unions with one major difference. Each group is
comprised of a type tag and a union of the types the union is capable of
representing. This is known as a tagged union.

The tag is used to inform the user application what type the union is currently
representing. The tag is a special enumeration that is automatically defined.

```ruby
group(:requests) do |g|
  c.field :add_user, :add_user_request
  c.field :get_user, :get_user_request
  c.field :delete_user, :delete_user_request
end

group(:responses) do |g|
  c.field :add_user, :add_user_response
  c.field :get_user, :get_user_response
  c.field :delete_user, :delete_user_response
end
```
