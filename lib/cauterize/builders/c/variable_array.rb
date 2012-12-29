module Cauterize
  module Builders
    module C
      class VariableArray < Buildable
        def render
          "struct #{@blueprint.name}"
        end

        def declare(formatter, sym)
          formatter << "struct #{@blueprint.name} #{sym};"
        end

        def packer_defn(formatter)
          size_type_builder = Builders.get(:c, @blueprint.size_type)
          array_type_builder = Builders.get(:c, @blueprint.array_type)

          formatter << packer_sig
          formatter.braces do
            formatter << "CAUTERIZE_STATUS_T err;"
            formatter << "size_t i;"
            formatter.blank_line
            # check the length
            formatter << "if (src->length > ARRAY_SIZE(src->data)) { return CA_ERR_INVALID_LENGTH; }"

            # store the length
            formatter << "if (CA_OK != (err = #{size_type_builder.packer_sym}(dst, &src->length))) { return err; }"
            formatter.blank_line

            # store each used item in the array
            formatter << "for (i = 0; i < src->length; i++)"
            formatter.braces do
              formatter << "if (CA_OK != (err = #{array_type_builder.packer_sym}(dst, &src->data[i]))) { return err; }"
            end
            formatter.blank_line

            formatter << "return CA_OK;"
          end
        end

        def unpacker_defn(formatter)
          size_type_builder = Builders.get(:c, @blueprint.size_type)
          array_type_builder = Builders.get(:c, @blueprint.array_type)

          formatter << unpacker_sig
          formatter.braces do
            formatter << "CAUTERIZE_STATUS_T err;"
            formatter << "size_t i;"
            formatter.blank_line

            # read the length
            formatter << "if (CA_OK != (err = #{size_type_builder.unpacker_sym}(src, &dst->length))) { return err; }"
            formatter.blank_line

            # check the length
            formatter << "if (dst->length > ARRAY_SIZE(dst->data)) { return CA_ERR_INVALID_LENGTH; }"
            formatter.blank_line


            # store each used item in the array
            formatter << "for (i = 0; i < dst->length; i++)"
            formatter.braces do
              formatter << "if (CA_OK != (err = #{array_type_builder.unpacker_sym}(src, &dst->data[i]))) { return err; }"
            end
            formatter.blank_line

            formatter << "return CA_OK;"
          end
        end

        def struct_proto(formatter)
          formatter << (render + ";")
        end

        def struct_defn(formatter)
          formatter << render
          formatter.braces do
            at_builder = Builders.get(:c, @blueprint.array_type)
            st_builder = Builders.get(:c, @blueprint.size_type)

            st_builder.declare(formatter, "length")
            formatter << "#{at_builder.render} data[#{@blueprint.array_size}];"
          end
          formatter.append(";")
        end
      end
    end
  end
end

Cauterize::Builders.register(:c, Cauterize::VariableArray, Cauterize::Builders::C::VariableArray)
