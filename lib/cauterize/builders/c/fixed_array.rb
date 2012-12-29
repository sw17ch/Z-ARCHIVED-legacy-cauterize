module Cauterize
  module Builders
    module C
      class FixedArray < Buildable
        def render
          # HEY! PAY ATTENTION!
          # Keep in mind that there's no sane way to "render" an array in C
          # that doesn't involve an identifier.
          ty_bldr.render
        end

        def declare(formatter, sym)
          formatter << "#{ty_bldr.render} #{sym}[#{@blueprint.array_size}]; /* #{@blueprint.name} */"
        end

        def packer_defn(formatter)
          formatter << packer_sig
          formatter.braces do
            formatter << "CAUTERIZE_STATUS_T err;"
            formatter << "size_t i;"
            formatter.blank_line

            # store each used item in the array
            formatter << "for (i = 0; i < #{@blueprint.array_size}; i++)"
            formatter.braces do
              formatter << "if (CA_OK != (err = #{ty_bldr.packer_sym}(dst, &src[i]))) { return err; }"
            end
            formatter.blank_line

            formatter << "return CA_OK;"
          end
        end

        def unpacker_defn(formatter)
          formatter << unpacker_sig
          formatter.braces do
            formatter << "CAUTERIZE_STATUS_T err;"
            formatter << "size_t i;"
            formatter.blank_line

            # store each used item in the array
            formatter << "for (i = 0; i < #{@blueprint.array_size}; i++)"
            formatter.braces do
              formatter << "if (CA_OK != (err = #{ty_bldr.unpacker_sym}(src, &dst[i]))) { return err; }"
            end
            formatter.blank_line

            formatter << "return CA_OK;"
          end
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
