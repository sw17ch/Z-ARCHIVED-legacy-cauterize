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
