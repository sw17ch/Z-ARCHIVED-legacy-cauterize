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
          formatter << packer_sig
          formatter.braces do
            formatter << "return CauterizeAppend(dst, (uint8_t*)src, sizeof(*src));"
          end
        end

        def unpacker_defn(formatter)
          formatter << unpacker_sig
          formatter.braces do
            formatter << "return CauterizeRead(src, (uint8_t*)dst, sizeof(*dst));"
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
