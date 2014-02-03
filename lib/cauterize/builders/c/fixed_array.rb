module Cauterize
  module Builders
    module C
      class FixedArray < Buildable
        def render
          "struct #{@blueprint.name}"
        end

        def declare(formatter, sym)
          formatter << "#{render} #{sym};"
        end

        def preprocessor_defines(formatter)
          formatter << "#define #{length_sym} (#{@blueprint.array_size})"
          formatter << "#define #{max_enc_len_cpp_sym} (#{length_sym} * #{ty_bldr.max_enc_len_cpp_sym})"
        end

        def packer_defn(formatter)
          formatter << "CAUTERIZE_STATUS_T err;"
          formatter << "size_t i;"
          formatter.blank_line

          # store each used item in the array
          formatter << "for (i = 0; i < #{length_sym}; i++)"
          formatter.braces do
            formatter << "if (CA_OK != (err = #{ty_bldr.packer_sym}(dst, &src->data[i]))) { return err; }"
          end
          formatter.blank_line

          formatter << "return CA_OK;"
        end

        def unpacker_defn(formatter)
          formatter << "CAUTERIZE_STATUS_T err;"
          formatter << "size_t i;"
          formatter.blank_line

          # store each used item in the array
          formatter << "for (i = 0; i < #{length_sym}; i++)"
          formatter.braces do
            formatter << "if (CA_OK != (err = #{ty_bldr.unpacker_sym}(src, &dst->data[i]))) { return err; }"
          end
          formatter.blank_line

          formatter << "return CA_OK;"
        end

        def struct_proto(formatter)
          formatter << (render + ";")
        end

        def struct_defn(formatter)
          formatter << render
          formatter.braces do
            formatter << "#{ty_bldr.render} data[#{@blueprint.array_size}];"
          end
          formatter.append(";")
        end

        private

        def length_sym
          "FIXED_ARRAY_LENGTH_#{@blueprint.name}"
        end

        def ty_bldr
          @ty_bldr ||= Builders.get(:c, @blueprint.array_type)
        end
      end
    end
  end
end

Cauterize::Builders.register(:c, Cauterize::FixedArray, Cauterize::Builders::C::FixedArray)
