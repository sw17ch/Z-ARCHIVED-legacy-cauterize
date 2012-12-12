describe Cauterize do
  before do
    @f = default_formatter
    reset_for_test
  end

  describe Atom do
    describe :format_decl do
      it "declares an atom" do
        atom(:foo).format_decl(@f, "bar")
        @f.to_s.should == "foo bar;"
      end
    end

    describe :format_h_proto do
      it "does nothing" do
        atom(:foo).format_h_proto(@f)
        @f.to_s.should == ""
      end
    end

    describe :format_h_defn do
      it "produces the packer" do
        atom(:foo).format_h_defn(@f)
        @f.to_s.should == "CAUTERIZE_STATUS_T Pack_foo(struct Cauterize * dst, foo * src);"
      end
    end

    describe :format_c_defn do
      it "is the definition of the packing function" do
        atom(:foo).format_c_defn(@f)
        @f.to_s.should == ""
      end
    end

    describe :render_c do
      it "renders the type" do
        atom(:foo).render_c.should == "foo"
      end
    end

    describe :pack_sym do
      it "is the symbol used for the packing function" do
        atom(:foo).pack_sym.should == "Pack_foo"
      end
    end
    describe :unpack_sym do
      it "is the symbol used for the unpacking function" do
        atom(:foo).pack_sym.should == "Unpack_foo"
      end
    end
  end
end
