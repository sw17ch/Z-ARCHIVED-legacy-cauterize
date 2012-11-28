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
    end
  end

  describe :enum_name do
    xit "is the name of the member's enumeration entry"
  end
end
