module Cauterize
  class FixedArray < BaseType
    def format_decl(f, decl, init=nil)
      raise Exception.new("Array size must be defined") unless @array_size
      raise Exception.new("Array type must be defined") unless @array_type

      f << "#{@array_type.name} #{decl}[#{@array_size}]; // Fixed Array :: #{@name}"
    end

    def format_h_proto(f)
      f << pack_signature + ";"
      f << unpack_signature + ";"
    end

    def format_h_defn(f)
      # do nothing
    end

    def format_c_defn(f)
      format_pack_defn(f)
      format_unpack_defn(f)
    end

    def render_c
      "#{@array_type.render_c}"
    end

    def pack_sym; "Pack_#{@name}" end
    def unpack_sym; "Unpack_#{@name}" end

    private

    # This is gross, but inevitable since C's types are ooky around fixed
    # length arrays. Perhaps there's a better way.
    def pack_signature
      "CAUTERIZE_STATUS_T #{pack_sym}(struct Cauterize * dst, #{@array_type.render_c} * src)"
    end
    def unpack_signature
      "CAUTERIZE_STATUS_T #{unpack_sym}(struct Cauterize * src, #{@array_type.render_c} * dst)"
    end

    def format_pack_defn(f)
      f << pack_signature
      f.braces do
        f << "CAUTERIZE_STATUS_T err;"
        f << "size_t i;"
        f.blank_line

        # store each used item in the array
        f << "for (i = 0; i < #{@array_size}; i++)"
        f.braces do
          f << "if (CA_OK != (err = #{@array_type.pack_sym}(dst, &src[i]))) { return err; }"
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

        # store each used item in the array
        f << "for (i = 0; i < #{@array_size}; i++)"
        f.braces do
          f << "if (CA_OK != (err = #{@array_type.unpack_sym}(src, &dst[i]))) { return err; }"
        end
        f.blank_line

        f << "return CA_OK;"
      end
    end
  end
end

