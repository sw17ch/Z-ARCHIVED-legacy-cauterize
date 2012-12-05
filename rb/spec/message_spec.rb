describe Message do
  describe :from_hash do
    it "makes a Message from a hash" do
      (fields = Object.new).expects(:map).returns(:fields)
      m = Message.from_hash({"message"=>{"fields"=>fields, "name"=>:name}})
      m.name.should == :name
      m.fields.should == :fields
    end

    it "validates the hash" do
      lambda {
        Message.from_hash({"message"=>{"fields"=>[],"name"=>nil}})
      }.should_not raise_error

      lambda {
        Message.from_hash({"foo"=>nil})
      }.should raise_error
    end
  end

  describe :initialize do
    it "makes a new Message" do
      Message.new(:name, :fields).name.should == :name
      Message.new(:name, :fields).fields.should == :fields
    end
  end

  describe :format_struct do
    it "uses a formatter to create a struct representing the message" do
      f = Field.new("f", "a[10]", "{0}", "a field")
      m = Message.new("foo", [f])

      formatter = Object.new
      formatter.expects(:struct).with("foo").yields(formatter)
      formatter.expects(:<<).with("/* a field */")
      formatter.expects(:<<).with("a f[10];")
      formatter.expects(:blank_line)

      m.format_struct(formatter)
    end
  end

  describe :format_with do
  end
end
