module Cauterize
  class VariableArray < BaseType
    def format_decl(f, decl)
      f << "struct #{@name} #{decl};"
    end

    def format_h_proto(f)
      format_struct_proto(f)
      format_pack_proto(f)
      format_unpack_proto(f)
    end

    def format_h_defn(f)
      f << "struct #{@name}"
      f.braces do
        @size_type.format_decl(f, :length)
        f << "#{@array_type.render_c} data[#{@array_size}];"
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

    def pack_sym; "Pack_struct_#{@name}" end
    def unpack_sym; "Unpack_struct_#{@name}" end

    private

    def format_struct_proto(f)
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
        f << "size_t i;"
        f.blank_line
        # check the length
        f << "if (src->length > ARRAY_SIZE(src->data)) { return CA_ERR_INVALID_LENGTH; }"

        # store the length
        f << "if (CA_OK != (err = #{@size_type.pack_sym}(dst, &src->length))) { return err; }"
        f.blank_line

        # store each used item in the array
        f << "for (i = 0; i < src->length; i++)"
        f.braces do
          f << "if (CA_OK != (err = #{@array_type.pack_sym}(dst, &src->data[i]))) { return err; }"
        end
        f.blank_line

        f << "return CA_OK;"
      end
    end
    def format_unpack_defn(f)
      f << unpack_signature
      f.braces do
        f << "CAUTERIZE_STATUS_T err;"
        f << "size_t i;"
        f.blank_line

        # read the length
        f << "if (CA_OK != (err = #{@size_type.unpack_sym}(src, &dst->length))) { return err; }"
        f.blank_line

        # check the length
        f << "if (dst->length > ARRAY_SIZE(dst->data)) { return CA_ERR_INVALID_LENGTH; }"
        f.blank_line


        # store each used item in the array
        f << "for (i = 0; i < dst->length; i++)"
        f.braces do
          f << "if (CA_OK != (err = #{@array_type.unpack_sym}(src, &dst->data[i]))) { return err; }"
        end
        f.blank_line

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
