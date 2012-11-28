describe GroupMember do
  describe :from_obj do
    it "Creates a GroupMember from String or a Hash" do
      GroupMember.from_obj({"name" => "foo"}).name.should == "foo"
      GroupMember.from_obj({"name" => "foo"}).sizeFunc.should be_nil
      GroupMember.from_obj({"name" => "foo", "size" => "sizeFunc"}).sizeFunc.should == "sizeFunc"
    end
  end

  describe :initialize do
    it "Creates a GroupMember" do
      GroupMember.new("foo").name.should == "foo"
      GroupMember.new("foo").sizeFunc.should be_nil
      GroupMember.new("foo", "nerp").sizeFunc.should == "nerp"
    end
  end

  describe :enum_name do
    it "is the name of the member's enumeration entry" do
      GroupMember.new("FooBar").enum_name.should =="FOO_BAR"
    end

    it "allows a prefix to be specified" do
      GroupMember.new("FooBar").enum_name("MEEP_").should =="MEEP_FOO_BAR"
    end
  end
end
