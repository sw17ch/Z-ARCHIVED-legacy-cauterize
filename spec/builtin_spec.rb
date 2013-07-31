module Cauterize

  describe BuiltIn do
    describe :initialize do
      it "creates a builtin" do
        b = BuiltIn.new(:foo)
        b.flavor(:unsigned)
        b.byte_length(4)
        
        b.name.should == :foo
        b.flavor.should == :unsigned
        b.byte_length.should == 4
      end
    end

    it { can_be_documented(BuiltIn) }
  end


  # Since the builtins are static, we make sure they are all defined here. They
  # should be created as part of the loading process. This is kinda evil.
  describe :builtins do
    Cauterize.builtins.keys.should =~ [
      :int8, :int16, :int32, :int64,
      :uint8, :uint16, :uint32, :uint64,
      :float32, :float64,
      :bool,
    ]
  end

  # We should not provide a way for people to build more builtin types directly.
  # This test ensures that there isn't a method to do so, but only by checking
  # that we haven't added the convention.
  #
  # I know, I know, testing negative behavior.
  describe :builtin do
    it "should not exist" do
      lambda {
        Cauterize.builtin(:foo)
      }.should raise_error /undefined method/
    end
  end
end
