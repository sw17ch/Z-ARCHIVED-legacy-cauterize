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

        def packer_defn(formatter)
          formatter << "CAUTERIZE_STATUS_T err;"
          formatter << "size_t i;"
          formatter.blank_line

          # store each used item in the array
          formatter << "for (i = 0; i < #{@blueprint.array_size}; i++)"
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
          formatter << "for (i = 0; i < #{@blueprint.array_size}; i++)"
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

        def ty_bldr
          @ty_bldr ||= Builders.get(:c, @blueprint.array_type)
        end
      end
    end
  end
end

Cauterize::Builders.register(:c, Cauterize::FixedArray, Cauterize::Builders::C::FixedArray)
