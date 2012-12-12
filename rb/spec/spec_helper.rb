require 'require_all'
require 'mocha/api'

RSpec.configure do |config|
  config.mock_framework = :mocha
end

files = Dir[File.dirname(__FILE__) + '/../lib/**/*.rb']
require_all files

###
include Cauterize

def reset_for_test
  BaseType.class_variable_set(:@@next_id, {})
  BaseType.class_variable_set(:@@instances, {})
end

def is_tagged_as(cls, tag)
  cls.new(:foo).tag.should == tag
end

def has_a_unique_id_for_each_instance(cls)
  cls.new(:foo).id.should == 0
  cls.new(:bar).id.should == 1
  cls.new(:baz).id.should == 2
end

def creates_a_named_object(fn_sym, obj)
  fn = method(fn_sym)
  a = fn.call(:foo)
  a.class.should == obj
  a.name.should == :foo
end

def retrieves_obj_with_identical_name(fn_sym)
  fn = method(fn_sym)
  a = fn.call(:foo)
  b = fn.call(:foo)
  a.should be b
end

def raises_exception_with_identical_name(fn_sym)
  fn = method(fn_sym)
  fn.call(:foo)
  lambda { fn.call(:foo) }.should raise_error
end

def yields_the_object(fn_sym)
  fn = method(fn_sym)
  called = false
  yielded = nil
  r = fn.call(:foo) { |a| yielded = a }
  yielded.should be r
end

def adds_object_to_hash(fn_sym, hash_fn_sym)
  fn = method(fn_sym)
  hash_fn = method(hash_fn_sym)

  f = fn.call(:foo)
  b = fn.call(:bar)

  hash_fn.call.keys.should == [:foo, :bar]
  hash_fn.call.values[0].should be f
  hash_fn.call.values[1].should be b
end

def is_hash_of_created_objs(create_fn_sym, hash_fn_sym)
  create_fn = method(create_fn_sym)
  hash_fn = method(hash_fn_sym)

  f = create_fn.call(:foo)
  b = create_fn.call(:bar)
  z = create_fn.call(:zap)

  vs = hash_fn.call.values
  vs[0].should be f
  vs[1].should be b
  vs[2].should be z
  hash_fn.call.keys.should == [:foo, :bar, :zap]
end


###############################################################################

def gen_test_main(sym_list)
  sym_voids = sym_list.map {|s| "(void*)#{s}"}.join(", ")
  str = <<-EOF
  #include "testing.h"

  int main(int argc, char * argv[])
  {
    (void)argc;
    (void)argv;

    void * ptr[] = {#{sym_voids}};
    (void)ptr;

    return 0;
  }
  EOF
end
