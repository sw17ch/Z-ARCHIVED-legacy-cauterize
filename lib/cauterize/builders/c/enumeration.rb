module Cauterize
  module Builders
    module C
      class Enumeration < Buildable
        def render
          "enum #{@blueprint.name.to_s}"
        end

        def declare(formatter, sym)
          formatter << "#{render} #{sym};"
        end

        def packer_defn(formatter)
          rep_builder = Builders.get(:c, @blueprint.representation)

          formatter << packer_sig
          formatter.braces do
            rep = "enum_representation"
            rep_builder.declare(formatter, rep)

            formatter << "#{rep} = (#{rep_builder.render})(*src);"
            formatter << "return #{rep_builder.packer_sym}(dst, &#{rep});"
          end
        end

        def unpacker_defn(formatter)
          rep_builder = Builders.get(:c, @blueprint.representation)

          formatter << unpacker_sig
          formatter.braces do
            rep = "enum_representation"
            rep_builder.declare(formatter, rep)

            formatter << "CAUTERIZE_STATUS_T s = #{rep_builder.unpacker_sym}(src, &#{rep});"
            formatter << "if (CA_OK != s)"
            formatter.braces do
              formatter << "return s;"
            end

            formatter << "else"
            formatter.braces do
              formatter << "*dst = (#{render})#{rep};"
              formatter << "return CA_OK;"
            end
          end
        end

        def enum_defn(formatter)
          formatter << render
          formatter.braces do
            @blueprint.values.values.each do |v|
              formatter << "#{v.name.to_s.up_snake} = #{v.value},"
            end
          end
          formatter.append(";")
        end
      end
    end
  end
end

Cauterize::Builders.register(:c, Cauterize::Enumeration, Cauterize::Builders::C::Enumeration)
