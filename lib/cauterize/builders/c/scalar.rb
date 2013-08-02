module Cauterize
  module Builders
    module C
      class Scalar < Buildable
        def render
          @blueprint.name.to_s
        end

        def typedef_decl(formatter)
          tn_bldr = Builders.get(:c, @blueprint.type_name)
          formatter << "typedef #{tn_bldr.render} #{render};"
        end

        def declare(formatter, sym)
          formatter << "#{render} #{sym};"
        end

        def packer_defn(formatter)
          formatter << "return CauterizeAppend(dst, (uint8_t*)src, sizeof(*src));"
        end

        def unpacker_defn(formatter)
          formatter << "return CauterizeRead(src, (uint8_t*)dst, sizeof(*dst));"
        end
      end
    end
  end
end

Cauterize::Builders.register(:c, Cauterize::Scalar, Cauterize::Builders::C::Scalar)
