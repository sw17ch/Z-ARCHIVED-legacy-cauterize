module Cauterize
  describe Scalar do
    describe :initialize do
      it "creates an scalar" do
        Cauterize.scalar(:foo).name.should == :foo
      end
    end

    describe :id do
      it { has_a_unique_id_for_each_instance(Scalar) }
    end

    describe :type_name do
      it "specifies the builtin type to alias" do
        s = Cauterize.scalar(:foo) do |t|
          t.type_name(:int8)
        end
      end

      it "raises an exception when a non-builtin is specified" do
        dummy = Cauterize.scalar(:dummy)
        s = Cauterize.scalar(:foo) do |t|
          t.type_name(:int32)
        end
      end
    end
  end

  describe :scalar do
    it { creates_a_named_object(:scalar, Scalar) }
    it { retrieves_obj_with_identical_name(:scalar) }
    it { yields_the_object(:scalar) }
    it { adds_object_to_hash(:scalar, Cauterize.scalars) }
  end

  describe :scalar! do
    it { creates_a_named_object(:scalar!, Scalar) }
    it { raises_exception_with_identical_name(:scalar!) }
    it { yields_the_object(:scalar!) }
    it { adds_object_to_hash(:scalar!, Cauterize.scalars) }
  end

  describe :scalars do
    it { is_hash_of_created_objs(:scalar, Cauterize.scalars) }
  end
end
