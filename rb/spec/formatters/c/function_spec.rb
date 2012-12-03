describe CFunction do
  before do
    @f = CFunction.new("foo", "bool", ["int32_t thing", "int64_t other_thing"])
  end

  describe :initialize do
    it "makes a function" do
      lambda {
        CFunction.new("foo", "bool", ["int32_t thing"])
      }.should_not raise_error
    end
  end

  describe :prototype do
    it "produces a prototype" do
      formatter = "formatter"
      field = "field"
      formatter.expects(:<<).with("bool foo(int32_t thing, int64_t other_thing);")
      @f.prototype(formatter)
    end
  end

  describe :definition do
    before do
      @formatter = "formatter"
      @field = "field"
      @formatter.expects(:<<).with("bool foo(int32_t thing, int64_t other_thing)")
      @formatter.expects(:braces).yields(@formatter)
    end

    it "produces a definition" do
      @f.definition(@formatter)
    end

    it "accepts a block" do
      @formatter.expects(:<<).with("return 0;")
      @f.definition(@formatter) do
        @formatter << "return 0;"
      end
    end
  end
end
