describe Cauterize do
  before do
    @f = default_formatter
    reset_for_test
  end

  describe FixedArray do
    before do
      atom(:atom)
      @c = composite(:composite) do |c|
        c.field :a, :atom
      end

      @a = fixed_array(:foo) do |f|
        f.array_type :composite
        f.array_size 16
      end
    end

    describe :format_decl do
      it "formats a declaration" do
        @a.format_decl(@f, :beep)
        @f.to_s.should == "composite beep[16]; // Fixed Array :: foo"
      end

      it "raises an error if size isn't defined" do
        lambda {
          atom(:atom)
          fixed_array(:nerp) do |fa|
            fa.array_type :atom
          end.format_decl(@f, :beep)
        }.should raise_error /size must be defined/
      end

      it "raises an error if type isn't defined" do
        lambda {
          atom(:atom)
          fixed_array(:nerp) do |fa|
            fa.array_size 96
          end.format_decl(@f, :beep)
        }.should raise_error /type must be defined/
      end
    end

    describe :format_h_proto do
      before { @a.format_h_proto(@f) }

      it "formats a packing function" do
        @f.to_s.should match Regexp.escape("CAUTERIZE_STATUS_T Pack_foo(struct Cauterize * dst, struct composite * src);")
      end

      it "formats an unpacking function" do
        @f.to_s.should match Regexp.escape("CAUTERIZE_STATUS_T Unpack_foo(struct Cauterize * src, struct composite * dst);")
      end
    end

    describe :format_h_defn do
      it "does nothing" do
        @a.format_h_defn(@f)
        @f.to_s.should == ""
      end
    end

    describe :format_c_defn do
      before { @a.format_c_defn(@f) }

      it "contains return statements" do
        @f.to_s.should match "return"
      end

      it "defines a packing function" do
        @f.to_s.should match "Pack_"
      end

      it "defines an unpacking function" do
        @f.to_s.should match "Unpack_"
      end
    end

    describe :render_c do
      it "renders the type" do
        @a.render_c.should == "struct composite"
      end
    end

    describe :pack_sym do
      it "is the symbol used for the packing function" do
        @a.pack_sym.should == "Pack_foo"
      end
    end
    describe :unpack_sym do
      it "is the symbol used for the unpacking function" do
        @a.unpack_sym.should == "Unpack_foo"
      end
    end
  end
end
