describe CEnum do
  before do
    @name = "an_enum"
    @members = ["a","b","c"]
  end

  describe :initialize do
    it "Makes a CEnum" do
      lambda { CEnum.new(@name, @members) }.should_not raise_error
    end
  end

  describe :prototype do
    it "should raise an error" do
      lambda { CEnum.new(@name, @members).prototype(:formatter) }.should raise_error
    end
  end

  describe :definition do
    it "should emit the enumeration's definition" do
      formatter = "formatter"
      members = "members"

      members.expects(:each).yields("a_member")
      formatter.expects(:<<).with("enum foo")
      formatter.expects(:braces).yields(formatter)
      formatter.expects(:<<).with("a_member,")
      formatter.expects(:blank_line)

      e = CEnum.new("foo", members).definition(formatter)
    end
  end
end
