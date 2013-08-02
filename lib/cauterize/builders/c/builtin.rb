module Cauterize
  module Builders
    module C
      class BuiltIn < Buildable
        @@C_TYPE_MAPPING = {
          1 => {signed:  :int8_t, unsigned:  :uint8_t, :float => nil,     :bool => :bool},
          2 => {signed: :int16_t, unsigned: :uint16_t, :float => nil,     :bool =>   nil},
          4 => {signed: :int32_t, unsigned: :uint32_t, :float => :float,  :bool =>   nil},
          8 => {signed: :int64_t, unsigned: :uint64_t, :float => :double, :bool =>   nil},
        }

        def render
          render_ctype
        end

        def declare(formatter, sym)
          formatter << "#{render} #{sym};"
        end

        # These are identical to the Scalar definitions. For now.
        def packer_defn(formatter)
          formatter << "return CauterizeAppend(dst, (uint8_t*)src, sizeof(*src));"
        end

        def unpacker_defn(formatter)
          formatter << "return CauterizeRead(src, (uint8_t*)dst, sizeof(*dst));"
        end

        private

        def render_ctype
          @@C_TYPE_MAPPING[@blueprint.byte_length][@blueprint.flavor]
        end
      end
    end
  end
end

Cauterize::Builders.register(:c, Cauterize::BuiltIn, Cauterize::Builders::C::BuiltIn)
