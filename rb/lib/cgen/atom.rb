module Cauterize
  class Atom < BaseType
    def format_decl(f, decl, init=nil)
      f << "#{@name} #{decl};"
    end

    def format_h_proto(f)
      # do nothing
    end

    def format_h_defn(f)
      format_pack_prototype(f)
      format_unpack_prototype(f)
    end

    def format_c_defn(f)
      format_pack_defn(f)
      format_unpack_defn(f)
    end

    def render_c
      @name.to_s
    end

    def pack_sym; "Pack_#{@name}" end
    def unpack_sym; "Unpack_#{@name}" end

    private

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
      "CAUTERIZE_STATUS_T #{pack_sym}(struct Cauterize * dst, #{render_c} * src)"
    end
    def unpack_signature
      "CAUTERIZE_STATUS_T #{unpack_sym}(struct Cauterize * src, #{render_c} * dst)"
    end
  end
end
