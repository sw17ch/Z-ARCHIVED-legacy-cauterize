module Cauterize
  class Group < BaseType
    def format_decl(f, decl, init=nil)
      f << "struct #{@name} #{decl};"
    end

    def format_h_proto(f)
      format_struct(f)
      format_pack_proto(f)
      format_unpack_proto(f)
    end

    def format_h_defn(f)
      en = tag_enumeration

      en.format_h_proto(f)
      f.blank_line
      f << "struct #{@name}"
      f.braces do
        en.format_decl(f, :tag)
        f << "union"
        f.braces do
          @fields.values.each do |v|
            v.type.format_decl(f, v.name)
          end
        end
        f.append(" data;")
      end
      f.append(";")
    end

    def format_c_defn(f)
      format_pack_defn(f)
      format_unpack_defn(f)
    end

    def render_c
      "struct #{@name}"
    end

    def tag_enumeration
      type_name = "group_#{@name}_type".to_sym

      @tag_enumeration ||= enumeration(type_name) do |e|
        @fields.values.each do |v|
          e.value field_enum_sym(v.name)
        end
      end
    end

    def pack_sym; "Pack_struct_#{@name}" end
    def unpack_sym; "Unpack_struct_#{@name}" end

    private

    # The symbol in the enumeration designated for the field
    def field_enum_sym(fname)
      "group_#{@name}_type_#{fname}".up_snake
    end

    def format_struct(f)
      f << "struct #{@name};"
    end

    def format_pack_proto(f)
      f << pack_signature + ";"
    end
    def format_unpack_proto(f)
      f << unpack_signature + ";"
    end

    def format_pack_defn(f)
      f << pack_signature
      f.braces do
        f << "CAUTERIZE_STATUS_T err;"

        # pack the tag
        f << "if (CA_OK != (err = #{@tag_enumeration.pack_sym}(dst, &src->tag))) { return err; }"

        # pack the fields
        f << "switch (src->tag)"
        f.braces do
          @fields.values.each do |field|
            f.backdent "case #{field_enum_sym(field.name)}:"
            f << "if (CA_OK != (err = #{field.type.pack_sym}(dst, &src->data.#{field.name}))) { return err; }"
            f << "break;"
          end

          f.backdent "default:"
          f << "return CA_ERR_INVALUD_TYPE_TAG;"
          f << "break;"
        end
        f << "return CA_OK;"
      end
    end
    def format_unpack_defn(f)
      f << unpack_signature
      f.braces do
        f << "CAUTERIZE_STATUS_T err;"

        # unpack the tag
        f << "if (CA_OK != (err = #{@tag_enumeration.unpack_sym}(src, &dst->tag))) { return err; }"

        # pack the fields
        f << "switch (dst->tag)"
        f.braces do
          @fields.values.each do |field|
            f.backdent "case #{field_enum_sym(field.name)}:"
            f << "if (CA_OK != (err = #{field.type.unpack_sym}(src, &dst->data.#{field.name}))) { return err; }"
            f << "break;"
          end

          f.backdent "default:"
          f << "return CA_ERR_INVALUD_TYPE_TAG;"
          f << "break;"
        end
        f << "return CA_OK;"
      end
    end

    def pack_signature
      "CAUTERIZE_STATUS_T #{pack_sym}(struct Cauterize * dst, #{render_c} * src)"
    end

    def unpack_signature
      "CAUTERIZE_STATUS_T #{unpack_sym}(struct Cauterize * src, #{render_c} * dst)"
    end
  end
end
