describe Cauterize do
  before do
    @f = default_formatter
    reset_for_test
  end

  describe Composite do
    before do
      @a = atom(:atom)
      @c = composite(:foo) do |c|
        c.field :a, :atom
      end
    end

    describe :format_decl do
      it "declares a composite structure" do
        @c.format_decl(@f, "bar")
        @f.to_s.should == "struct foo bar;"
      end
    end

    describe :format_h_proto do
      before { @c.format_h_proto(@f) }

      it "defines the prototype" do
        @f.to_s.should match "struct foo;"
      end

      it "defines the pack prototype" do
        @f.to_s.should match Regexp.new(Regexp.escape (
          "CAUTERIZE_STATUS_T Pack_struct_foo(struct Cauterize * dst, struct foo * src);"
        ))
      end

      it "defines the unpack prototype" do
        @f.to_s.should match Regexp.new(Regexp.escape (
          "CAUTERIZE_STATUS_T Unpack_struct_foo(struct Cauterize * src, struct foo * dst);"
        ))
      end
    end

    describe :format_h_defn do
      before { @c.format_h_defn(@f) }

      it "defines the structure" do
        @f.to_s.should match Regexp.new(Regexp.escape [
                              "struct foo",
                              "{",
                              "  atom a;",
                              "};",
                            ].join("\n"))
      end
    end

    describe :format_c_defn do
      before { @c.format_c_defn(@f) }

      it "contains return statements" do
        @f.to_s.should match "return"
      end

      it "formats the packing function" do
        @f.to_s.should match "Pack_"
      end

      it "formats the unpacking function" do
        @f.to_s.should match "Unpack_"
      end
    end

    describe :render_c do
      it "renders the type" do
        @c.render_c.should == "struct foo"
      end
    end

    describe :pack_sym do
      it "is the symbol used for the packing function" do
        @c.pack_sym.should == "Pack_struct_foo"
      end
    end
  end
end
