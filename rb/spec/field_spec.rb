describe Field do
  describe :from_hash do
    it "creates a Field from a hash" do
      hash = {
        "name" => "foo",
        "type" => "uint64_t[32]",
        "init" => "{0}",
        "description" => "A description"
      }

      f = Field.from_hash(hash)
      f.name.should == "foo"
      f.type.type_str.should == "uint64_t"
      f.type.array_str.should == "[32]"
      f.init.should == "{0}"
      f.desc.should == "A description"
    end
  end

  describe :initialize do
    it "creates a Field" do
      f = Field.new("foo", "uint64_t[32]", "{0}", "A description")
      f.name.should == "foo"
      f.type.type_str.should == "uint64_t"
      f.type.array_str.should == "[32]"
      f.init.should == "{0}"
      f.desc.should == "A description"
    end
  end

  describe :format do
    it "renders as a declaration with <<" do
      f = Field.new("foo", "uint64_t[32]", "{0}", "A description")
      formatter = []
      f.format(formatter)
      formatter[0].should == "/* A description */"
      formatter[1].should == "uint64_t foo[32];"
    end
  end
end
