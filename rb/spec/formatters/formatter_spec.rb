describe Formatter do
  before do
    @f = Formatter.new
  end

  describe :initialize do
    it "makes a Formatter" do
      lambda { Formatter.new }.should_not raise_error
    end
  end

  describe :indent do
    it "indents the line according to current indentation settings" do
      @f.instance_variable_set(:@indent_level, 1)
      @f.indent("foo").should == "  foo"
      @f.instance_variable_set(:@indent_level, 2)
      @f.indent("foo").should == "    foo"
      @f.instance_variable_set(:@indent_level, 0)
      @f.indent("foo").should == "foo"
    end
  end

  describe :<< do
    it "adds a line to lines" do
      @f << "foo"
      @f.instance_variable_get(:@lines).should == ["foo"]
      @f << "bar"
      @f.instance_variable_get(:@lines).should == ["foo", "bar"]
    end
  end

  describe :append do
    it "adds text to the last line" do
      @f << "foo"
      @f << "bar"
      @f.append("!!!")
      @f.instance_variable_get(:@lines).should == ["foo", "bar!!!"]
    end
  end

  describe :braces do
    it "places braces around any text added in the block" do
      @f.braces do
        @f << "foo"
        @f << "bar"
      end

      @f.instance_variable_get(:@lines).should == ["{", "  foo", "  bar", "}"]
    end
  end

  describe :to_s do
    before do
      @f.braces do
        @f << "foo"
        @f << "bar"
      end
    end

    it "creates a string representation for the accumulated data" do
      @f.to_s.should == "{\n  foo\n  bar\n}"
    end

    it "accepts an extra indentation level to apply to all text" do
      @f.to_s(2).should == "    {\n      foo\n      bar\n    }"
    end
  end
end
