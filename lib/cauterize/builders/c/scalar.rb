module Cauterize
  module Builders
    module C
      class Scalar < Buildable
        def render
          @blueprint.name.to_s
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
      end
    end
  end
end

Cauterize::Builders.register(:c, Cauterize::Scalar, Cauterize::Builders::C::Scalar)
