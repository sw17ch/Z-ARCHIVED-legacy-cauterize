module Cauterize::Builders::CS
  class Scalar < Buildable
    @@type_map = {
      int8_t:  "SByte",
      int16_t: "Int16",
      int32_t: "Int32",
      int64_t: "Int64",
      uint8_t: "Byte",
      uint16_t: "UInt16",
      uint32_t: "UInt32",
      uint64_t: "UInt64"
    }
    def render
      @@type_map[@blueprint.name]
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::Scalar, Cauterize::Builders::CS::Scalar)
