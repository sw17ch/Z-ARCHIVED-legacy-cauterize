module Cauterize
  describe Cauterize do
    describe CompositeField do
      describe :initialize do
        it "creates a new name -> type mapping" do
          a = Cauterize.scalar(:a_type)
          b = Cauterize.scalar(:b_type)
          f = CompositeField.new(:a_name, :a_type)
          f.name.should == :a_name
          f.type.should be a
        end
      end
    end

    describe Composite do
      describe :initialize do
        it "creates a Composite" do
          c = Composite.new(:foo)
          c.name.should == :foo
        end
      end

      describe :fields do
        it "defines a new field in the composite" do
          a = Cauterize.scalar(:foo)
          comp = Cauterize.composite(:comp) do |c|
            c.field :a_foo, :foo
          end

          comp.fields.keys[0].should == :a_foo
          comp.fields.values[0].name.should == :a_foo
          comp.fields.values[0].type.should be a
        end

        it "errors on duplicate field names" do
          a = Cauterize.scalar(:foo)
          lambda {
            Cauterize.composite(:comp) do |c|
              c.field :a_foo, :foo
              c.field :b_foo, :foo
              c.field :b_foo, :foo
            end
          }.should raise_error /Field name b_foo already used/
        end
      end
    end

    describe :composite do
      it { creates_a_named_object(:composite, Composite) }
      it { retrieves_obj_with_identical_name(:composite) }
      it { yields_the_object(:composite) }
      it { adds_object_to_hash(:composite, Cauterize.composites) }
    end

    describe :composite! do
      it { creates_a_named_object(:composite!, Composite) }
      it { raises_exception_with_identical_name(:composite!) }
      it { yields_the_object(:composite!) }
      it { adds_object_to_hash(:composite!, Cauterize.composites) }
    end

    describe :composites do
      it { is_hash_of_created_objs(:composite, Cauterize.composites) }
    end
  end
end
