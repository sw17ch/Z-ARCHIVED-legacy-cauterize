describe Cauterize do
  before do
    @f = default_formatter
    reset_for_test
  end

  describe Group do
    before do
      @a = scalar(:scalar)
      @c = composite(:composite) do |c|
        c.field :a, :scalar
      end
      @g = group(:a_group) do |g|
        g.field :a, :scalar
        g.field :c, :composite
      end
    end

    describe :format_decl do
      it "declares a group" do
        @g.format_decl(@f, :foo)
        @f.to_s.should == "struct a_group foo;"
      end
    end

    describe :format_h_proto do
      before { @g.format_h_proto(@f) }

      it "prototypes the struct" do
        @f.to_s.should match "struct a_group;"
      end

      it "prototypes the packer" do
        @f.to_s.should match Regexp.new(Regexp.escape(
          "CAUTERIZE_STATUS_T Pack_struct_a_group(struct Cauterize * dst, struct a_group * src);"
        ))
      end

      it "prototypes the unpacker" do
        @f.to_s.should match Regexp.new(Regexp.escape(
          "CAUTERIZE_STATUS_T Unpack_struct_a_group(struct Cauterize * src, struct a_group * dst);"
        ))
      end
    end

    describe :format_h_defn do
      it "defines the struct and its enumerable tag" do
        @g.format_h_defn(@f)
        @f.to_s.should ==
          [
            "enum group_a_group_type",
            "{",
            "  GROUP_A_GROUP_TYPE_A = 0,",
            "  GROUP_A_GROUP_TYPE_C = 1,",
            "};",
            "CAUTERIZE_STATUS_T Pack_enum_group_a_group_type(struct Cauterize * dst, enum group_a_group_type * src);",
            "CAUTERIZE_STATUS_T Unpack_enum_group_a_group_type(struct Cauterize * src, enum group_a_group_type * dst);",
            "",
            "struct a_group",
            "{",
            "  enum group_a_group_type tag;",
            "  union",
            "  {",
            "    scalar a;",
            "    struct composite c;",
            "  } data;",
            "};"
          ].join("\n")
      end
    end

    describe :format_c_defn do
      before { @g.format_c_defn(@f) }

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
        @g.render_c.should == "struct a_group"
      end
    end

    describe :pack_sym do
      it "is the symbol used for the packing function" do
        @g.pack_sym.should == "Pack_struct_a_group"
      end
    end
    describe :unpack_sym do
      it "is the symbol used for the unpacking function" do
        @g.unpack_sym.should == "Unpack_struct_a_group"
      end
    end
  end
end
