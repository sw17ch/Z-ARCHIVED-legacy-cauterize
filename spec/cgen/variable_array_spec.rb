describe Cauterize do
  before do
    @f = default_formatter
    reset_for_test
  end

  describe VariableArray do
    before do
      scalar(:uint16_t)
      scalar(:scalar)

      @v = variable_array(:va) do |v|
        v.array_type :scalar
        v.array_size 16
        v.size_type :uint16_t
      end
    end

    describe :format_decl do
      it "formats a variable array declaration" do
        @v.format_decl(@f, :doop)
        @f.to_s.should == "struct va doop;"
      end
    end

    describe :format_h_proto do
      before { @v.format_h_proto(@f) }

      it "formats the struct prototype" do
        @f.to_s.should match /struct va;/
      end

      it "formats the packer prototype" do
        @f.to_s.should match Regexp.new(Regexp.escape(
          "CAUTERIZE_STATUS_T Pack_struct_va(struct Cauterize * dst, struct va * src);"
        ))
      end
    end

    describe :format_h_defn do
      it "formats the struct definition" do
        @v.format_h_defn(@f)
        @f.to_s.should == [
          "struct va",
          "{",
          "  uint16_t length;",
          "  scalar data[16];",
          "};"
        ].join("\n")
      end
    end

    describe :format_c_defn do
      before { @v.format_c_defn(@f) }

      it "defines a packer" do
        @f.to_s.should match /Pack_/
      end

      it "defines an unpacker" do
        @f.to_s.should match /Unpack_/
      end
    end

    describe :render_c do
      it "renders the type" do
        @v.render_c.should == "struct va"
      end
    end

    describe :pack_sym do
      it "is the symbol used for the packing function" do
        @v.pack_sym.should == "Pack_struct_va"
      end
    end
    describe :unpack_sym do
      it "is the symbol used for the unpacking function" do
        @v.unpack_sym.should == "Unpack_struct_va"
      end
    end
  end
end
