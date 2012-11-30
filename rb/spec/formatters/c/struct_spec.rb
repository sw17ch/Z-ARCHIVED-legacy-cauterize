describe CStruct do
  describe :initialize do
    it "saves the name and fields" do
      CStruct.new(:name, :fields).name.should == :name
      CStruct.new(:name, :fields).fields.should == :fields
    end
  end

  describe :prototype do
    it "adds the prototype to the formatter" do
      (formatter = "formatter").expects(:<<).with("struct foo;").yields(formatter)
      CStruct.new("foo", []).prototype(formatter)
    end
  end

  describe :definition do
    it "adds the definition to the formatter" do
      formatter = "formatter"
      field = "field"

      formatter.expects(:<<).with("struct foo")
      formatter.expects(:braces).yields
      field.expects(:format).with(formatter)
      formatter.expects(:append).with(";")
      formatter.expects(:blankline)

      CStruct.new("foo", [field]).definition(formatter)
    end
  end
end
