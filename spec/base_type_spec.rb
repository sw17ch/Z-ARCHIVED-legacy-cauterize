include Cauterize

describe Cauterize do
  before {
    BaseType.class_variable_set(:@@next_id, {})
    BaseType.class_variable_set(:@@instances, {})
  }

  describe BaseType do
    describe :id do
      it { has_a_unique_id_for_each_instance(BaseType) }
    end

    describe :type_str do
      it "is the hexadecimal representation of type" do
        f = enumeration(:foo) do |e|
          e.value :a, 1
        end
        b = enumeration(:bar) do |e|
          e.value :a, 1
        end

        b.type_str.should == "0x2001"
      end
    end

    describe :tag do
      it { is_tagged_as(Scalar, 0) }
      it { is_tagged_as(Enumeration, 1) }
      it { is_tagged_as(Composite, 2) }
      it { is_tagged_as(FixedArray, 3) }
      it { is_tagged_as(VariableArray, 4) }
      it { is_tagged_as(Group, 5) }
    end

    describe :next_id do
      it "is an incrementing value starting at 0" do
        # the .new consumes the 0.
        BaseType.new(:foo).instance_exec do
          next_id.should == 1
          next_id.should == 2
          next_id.should == 3
          next_id.should == 4
        end
      end

      it "should not allow derived class ids to interact" do
        a1 = Scalar.new(:foo)
        a2 = Scalar.new(:bar)
        e1 = Enumeration.new(:zoop)
        e2 = Enumeration.new(:nih)

        a1.id.should == 0
        a2.id.should == 1
        e1.id.should == 0
        e2.id.should == 1
      end
    end

    describe "bit stuff" do
      it "is consistent" do
        BaseType.class_exec do
          (tag_bit_width + id_bit_width).should == type_bit_width
          (tag_bit_mask >> id_bit_width).should == 0x7
        end
      end
    end

    describe :register_instance do
      it "adds an instance to the instance list" do
        class X < BaseType
          def initialize(name); end
        end
        x = X.new(:foo)

        x.instance_exec do
          register_instance(x)
        end

        BaseType.all_instances[0].should be x
        BaseType.all_instances.length.should == 1
      end
    end

    describe :instances do
      # Two things are being tested here.
      # 1. That instances works.
      # 2. That super() is called in each .new
      it "is every instance of a BaseType-derived class" do
        BaseType.all_instances.should == []

        a = Scalar.new(:foo)
        e = Enumeration.new(:emoo)
        c = Composite.new(:cooo)
        f = FixedArray.new(:moo)
        v = VariableArray.new(:quack)
        g = Group.new(:goo)

        lst = [a, e, c, f, v, g]

        instances = BaseType.all_instances
        instances.length.should == lst.length
        instances.zip(lst).each do |a,b|
          a.should be b
        end
      end
    end

    describe :find_type do
      it "returns the instance with the provided name" do
        f = scalar(:foo)
        b = scalar(:bar)

        BaseType.find_type(:bar).should be b
        BaseType.find_type(:foo).should be f
      end

      it "is nil on an unknown name" do
        BaseType.find_type(:xxxxxxxxxxxxxxxxxx).should be_nil
      end
    end

    describe :find_type! do
      it "returns the instance with the provided name" do
        f = scalar(:foo)
        b = scalar(:bar)

        BaseType.find_type!(:bar).should be b
        BaseType.find_type!(:foo).should be f
      end

      it "errors on an unknown name" do
        lambda { BaseType.find_type!(:foo) }.should raise_error /name foo does not/
      end
    end

    describe "is_[type]?" do
      it "supports scalar" do
        scalar(:foo).is_scalar?.should be_true
      end

      it "supports enumeration" do
        enumeration(:foo).is_enumeration?.should be_true
      end

      it "supports composite" do
        composite(:foo).is_composite?.should be_true
      end

      it "supports fixed_array" do
        fixed_array(:foo).is_fixed_array?.should be_true
      end

      it "supports variable_array" do
        variable_array(:foo).is_variable_array?.should be_true
      end

      it "supports group" do
        group(:foo).is_group?.should be_true
      end
    end
  end
end
