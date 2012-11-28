describe Type do
  describe :parse do
    it "parses a string to a type" do
      Type.parse("a_type").type_str.should == "a_type"
      Type.parse("a_type[10]").array_str.should == "[10]"
      Type.parse("a_type[SOME_VAL]").array_str.should == "[SOME_VAL]"
    end
  end

  describe :initialize do
    it "creates a Type" do
      Type.new("a_type").type_str.should == "a_type"
      Type.new("a_type", "30").array_str.should == "[30]"
    end
  end

  describe :type_str do
    it "represents the type" do
      Type.new("a_type").type_str.should == "a_type"
    end
  end

  describe :array_str do
    it "represents any array portion" do
      Type.parse("a_type[FOO]").array_str.should == "[FOO]"
      Type.parse("a_type").array_str.should == ""
    end
  end
end
