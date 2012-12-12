describe Cauterize do
  before { reset_for_test }

  describe :group do
    it { creates_a_named_object(:group, Group) }
    it { retrieves_obj_with_identical_name(:group) }
    it { yields_the_object(:group) }
    it { adds_object_to_hash(:group, :groups) }
  end

  describe :group! do
    it { creates_a_named_object(:group!, Group) }
    it { raises_exception_with_identical_name(:group!) }
    it { yields_the_object(:group!) }
    it { adds_object_to_hash(:group!, :groups) }
  end

  describe :groups do
    it "is all the defined groups" do
      group(:a)
      group(:b)
      groups.values.map(&:name).should == [:a, :b]
    end
  end

  describe GroupField do
    describe :initialize do
      it "creats a GroupField" do
        t = scalar(:type)
        f = GroupField.new(:name, :type)
        f.name.should == :name
        f.type.should be t
      end
    end
  end

  describe Group do
    describe :initialize do
      it "makes a new Group" do
        Group.new(:foo).name == :foo
      end
    end

    describe :field do
      it "adds a field to the Group" do
        a = scalar(:aaa)
        b = scalar(:bbb)
        grp = group(:foo) do |g|
          g.field(:a, :aaa)
          g.field(:b, :bbb)
        end

        grp.fields.values.map(&:name).should == [:a, :b]
      end

      it "errors on duplicate field names" do
        a = scalar(:aaa)
        lambda {
          grp = group(:foo) do |g|
            g.field(:a, :aaa)
            g.field(:a, :aaa)
          end
        }.should raise_error /Field name a already used/
      end

      it "errors on non-existant types" do
        lambda {
          grp = group(:foo) do |g|
            g.field(:a, :aaa)
          end
        }.should raise_error /name aaa does not correspond to a type/
      end

      xit "errors on recursive definitions"
    end
  end
end
