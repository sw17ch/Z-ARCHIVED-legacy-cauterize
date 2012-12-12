describe Cauterize do
  before do
    reset_for_test

    @f = default_formatter
    @e = enumeration(:foo) do |enum|
      enum.value :a
      enum.value :b, 9
      enum.value :c
    end
  end

  describe "Enumeration" do
    describe :format_decl do
      it "declares an enumeration" do
        @e.format_decl(@f, :nerp)
        @f.to_s.should == "enum foo nerp;"
      end
    end

    describe :format_h_proto do
      before { @e.format_h_proto(@f) }

      it "formats an enumeration definition" do
        @f.to_s.should match Regexp.new(Regexp.escape [
                                          "enum foo" ,
                                          "{",
                                          "  A = 0,",
                                          "  B = 9,",
                                          "  C = 10,",
                                          "};"
                                        ].join("\n"))
      end

      it "formats a packing prototype" do
        @f.to_s.should match Regexp.new(Regexp.escape(
          "CAUTERIZE_STATUS_T Pack_enum_foo(struct Cauterize * dst, enum foo * src);"
        ))
      end

      it "formats a unpacking prototype" do
        @f.to_s.should match Regexp.new(Regexp.escape(
          "CAUTERIZE_STATUS_T Unpack_enum_foo(struct Cauterize * src, enum foo * dst);"
        ))
      end
    end

    describe :format_h_defn do
      it "does nothing" do
        @e.format_h_defn(@f)
        @f.to_s.should == ""
      end
    end

    describe :format_c_defn do
      before { @e.format_c_defn(@f) }

      it "contains return statements" do
        @f.to_s.should match "return"
      end

      it "formats the unpacking function" do
        @f.to_s.should match "Unpack_"
      end

      it "formats the packing function" do
        @f.to_s.should match "Pack_"
      end
    end

    describe :render_c do
      it "renders the type" do
        @e.render_c.should == "enum foo"
      end
    end

    describe :pack_sym do
      it "is the symbol used for the packing function" do
        @e.pack_sym.should == "Pack_enum_foo"
      end
    end

    describe :unpack_sym do
      it "is the symbol used for the packing function" do
        @e.unpack_sym.should == "Unpack_enum_foo"
      end
    end
  end
end
