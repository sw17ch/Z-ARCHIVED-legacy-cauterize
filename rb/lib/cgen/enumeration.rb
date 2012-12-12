module Cauterize
  class Enumeration < BaseType
    def format_decl(f, decl)
      f << "enum #{@name} #{decl};"
    end

    # TODO: Think about renaming this. The Enumeration 'body' has to be defined
    # as a prototype so that its name exists when we prototype the packing
    # function.
    def format_h_proto(f)
      format_enum_body(f)
      format_pack_prototype(f)
      format_unpack_prototype(f)
    end

    def format_h_defn(f)
      # do nothing
    end

    def format_c_defn(f)
      format_pack_defn(f)
      format_unpack_defn(f)
    end

    def render_c
      "enum #{@name.to_s}"
    end

    def pack_sym; "Pack_enum_#{@name}" end
    def unpack_sym; "Unpack_enum_#{@name}" end

    private

    def format_enum_body(f)
      f << "enum #{@name}"
      f.braces do
        @values.values.each do |v|
          f << "#{v.name.to_s.up_snake} = #{v.value},"
        end
      end
      f.append(";")
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
        f << "return CauterizeAppend(dst, (uint8_t*)src, sizeof(*src));"
      end
    end
    def format_unpack_defn(f)
      f << unpack_signature
      f.braces do
        f << "return CauterizeRead(src, (uint8_t*)dst, sizeof(*dst));"
      end
    end

    def pack_signature
      "CAUTERIZE_STATUS_T #{pack_sym}(struct Cauterize * dst, enum #{@name} * src)"
    end

    def unpack_signature
      "CAUTERIZE_STATUS_T #{unpack_sym}(struct Cauterize * src, enum #{@name} * dst)"
    end
  end
end
