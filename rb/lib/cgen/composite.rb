module Cauterize
  class Composite < BaseType
    def format_decl(f, decl, init=nil)
      f << "struct #{@name} #{decl};"
    end

    def format_h_proto(f)
      format_struct_prototype(f)
      format_pack_prototype(f)
      format_unpack_prototype(f)
    end

    def format_h_defn(f)
      f << "struct #{@name}"
      f.braces do
        @fields.values.each do |field|
          field.type.format_decl(f, field.name)
        end
      end
      f.append(";")
    end

    def format_c_defn(f)
      format_pack_defn(f)
      format_unpack_defn(f)
    end

    def render_c
      "struct #{@name.to_s}"
    end

    def pack_sym; "Pack_struct_#{@name}" end
    def unpack_sym; "Unpack_struct_#{@name}" end

    private

    def format_struct_prototype(f)
      f << "struct #{@name};"
    end

    def format_pack_prototype(f)
      f << pack_signature + ";"
    end

    def format_unpack_prototype(f)
      f << unpack_signature + ";"
    end

    def format_pack_defn(f)
      f << pack_signature
      f.braces do
        f << "CAUTERIZE_STATUS_T err;"
        @fields.values.each do |field|
          f << "if (CA_OK != (err = #{field.type.pack_sym}(dst, &src->#{field.name}))) { return err; }"
        end
        f << "return CA_OK;"
      end
    end
    def format_unpack_defn(f)
      f << unpack_signature
      f.braces do
        f << "CAUTERIZE_STATUS_T err;"
        @fields.values.each do |field|
          f << "if (CA_OK != (err = #{field.type.unpack_sym}(src, &dst->#{field.name}))) { return err; }"
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
