module Cauterize

  describe Cauterize do
    describe BaseType do
      describe :description do
        it "handles nil description" do
          BaseType.new(:foo, nil).description.should be_nil
        end

        it "sets the description" do
          BaseType.new(:foo, "a desc").description.should == "a desc"
        end
      end

      describe :register_instance do
        it "adds an instance to the instance list" do
          orig_len = BaseType.all_instances.length

          class X < BaseType
            def initialize(name); end
          end
          x = X.new(:foo)

          x.instance_exec do
            register_instance(x)
          end

          BaseType.all_instances.last.should be x
          BaseType.all_instances.length.should == orig_len + 1
        end
      end

      describe :instances do
        # Two things are being tested here.
        # 1. That instances works.
        # 2. That super() is called in each .new
        it "is every instance of a BaseType-derived class" do
          BaseType.class_variable_set(:@@instances, {})

          b = BuiltIn.new(:uint32)
          s = Scalar.new(:eek)
          e = Enumeration.new(:emoo)
          c = Composite.new(:cooo)
          f = FixedArray.new(:moo)
          v = VariableArray.new(:quack)
          g = Group.new(:goo)

          lst = [b, s, e, c, f, v, g]

          instances = BaseType.all_instances

          # There will be some extras due to automatic creation of enums and
          # scalars in Enumeration and Group.
          instances.should include(*lst)

          # Check that each of our instances shows up in the list returned from
          # all_instances. Do it this way in case there are other types created
          # (like the enumeration for Group).
          lst.all? do |l|
            instances.any? {|i| i.equal? l}
          end
        end
      end

      describe :type_hash do
        it "is different for objects with different names" do
          f = Cauterize.scalar(:foo) {|t| t.type_name :uint8}.type_hash
          g = Cauterize.scalar(:bar) {|t| t.type_name :uint8}.type_hash

          f.should_not == g
        end

        it "is different for objects with different types" do
          f = Cauterize.scalar(:foo) {|t| t.type_name :uint8}.type_hash
          reset_for_test

          g = Cauterize.scalar(:foo) {|t| t.type_name :int8}.type_hash
          reset_for_test

          f.should_not == g
        end

        it "differes on enumeration value differences" do
          f = Cauterize.enumeration(:foo) { |t| t.value :a, 0 }.type_hash
          reset_for_test

          g = Cauterize.enumeration(:foo) { |t| t.value :a, 1 }.type_hash
          reset_for_test

          f.should_not == g
        end

        it "differs on differing length in fixed arrays" do
          f = Cauterize.fixed_array(:foo) { |t| t.array_type :int8; t.array_size 1 }.type_hash
          reset_for_test

          g = Cauterize.fixed_array(:foo) { |t| t.array_type :int8; t.array_size 2 }.type_hash
          reset_for_test

          f.should_not == g
        end

        it "differs on differing size type in variable arrays" do
          f = Cauterize.variable_array(:foo) { |t| t.array_type :int8; t.array_size 2 }.type_hash
          reset_for_test

          g = Cauterize.variable_array(:foo) { |t| t.array_type :int8; t.array_size 2000 }.type_hash
          reset_for_test

          f.should_not == g
        end

        it "differs on group field reordering" do
          f = Cauterize.group(:foo) do |t|
            t.field :a, :int8
            t.field :b, :int8
          end.type_hash
          reset_for_test

          g = Cauterize.group(:foo) do |t|
            t.field :b, :int8
            t.field :a, :int8
          end.type_hash
          reset_for_test

          f.should_not == g
        end

        it "differs on composite field reordering" do
          f = Cauterize.composite(:foo) do |t|
            t.field :a, :int8
            t.field :b, :int8
          end.type_hash
          reset_for_test

          g = Cauterize.composite(:foo) do |t|
            t.field :b, :int8
            t.field :a, :int8
          end.type_hash
          reset_for_test

          f.should_not == g
        end

        it "differs on changes in indirect fields" do
          Cauterize.scalar(:a_thing) { |t| t.type_name :int8 }
          f = Cauterize.composite(:foo) do |t|
            t.field :a, :a_thing
          end.type_hash
          reset_for_test

          Cauterize.scalar(:a_thing) { |t| t.type_name :uint8 }
          g = Cauterize.composite(:foo) do |t|
            t.field :a, :a_thing
          end.type_hash
          reset_for_test

          f.should_not == g
        end
      end

      describe :model_hash do
        it "returns a SHA1 of the model" do
          Cauterize.scalar(:foo) {|t| t.type_name :uint8}

          h = BaseType.model_hash
          h.should_not be_nil
          h.length.should == 20 # length of sha1
        end

        it "is supported by all the types" do
          gen_a_model
          h = BaseType.model_hash
          h.should_not be_nil
          h.length.should == 20 # length of sha1
        end

        it "differs on different models" do
          gen_a_model
          a = BaseType.model_hash
          reset_for_test

          gen_b_model
          b = BaseType.model_hash
          reset_for_test

          a.should_not == b
        end
      end

      describe :find_type do
        it "returns the instance with the provided name" do
          f = Cauterize.scalar(:foo)
          b = Cauterize.scalar(:bar)

          BaseType.find_type(:bar).should be b
          BaseType.find_type(:foo).should be f
        end

        it "is nil on an unknown name" do
          BaseType.find_type(:xxxxxxxxxxxxxxxxxx).should be_nil
        end
      end

      describe :find_type! do
        it "returns the instance with the provided name" do
          f = Cauterize.scalar(:foo)
          b = Cauterize.scalar(:bar)

          BaseType.find_type!(:bar).should be b
          BaseType.find_type!(:foo).should be f
        end

        it "errors on an unknown name" do
          lambda { BaseType.find_type!(:foo) }.should raise_error /name foo does not/
        end
      end

      describe "is_[type]?" do
        it "supports scalar" do
          Cauterize.scalar(:foo).is_scalar?.should be_true
        end

        it "supports enumeration" do
          Cauterize.enumeration(:foo).is_enumeration?.should be_true
        end

        it "supports composite" do
          Cauterize.composite(:foo).is_composite?.should be_true
        end

        it "supports fixed_array" do
          Cauterize.fixed_array(:foo).is_fixed_array?.should be_true
        end

        it "supports variable_array" do
          Cauterize.variable_array(:foo).is_variable_array?.should be_true
        end

        it "supports group" do
          Cauterize.group(:foo).is_group?.should be_true
        end

        it "supports builtin" do
          # This one is special because of how buitins are declared
          Cauterize.builtins[:int32].is_built_in?.should be_true
        end
      end
    end
  end
end
