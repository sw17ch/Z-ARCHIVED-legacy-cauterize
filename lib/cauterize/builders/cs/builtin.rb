module Cauterize::Builders::CS
  class BuiltIn < Buildable
    @@CS_TYPE_MAPPING = {
      1 => {signed: "SByte", unsigned: "Byte"},
      2 => {signed: "Int16", unsigned: "UInt16"},
      4 => {signed: "Int32", unsigned: "UInt32"},
      8 => {signed: "Int64", unsigned: "UInt64"},
    }

    def render
      render_cstype
    end

    private

    def render_cstype
      s_key = @blueprint.is_signed ? :signed : :unsigned
      @@CS_TYPE_MAPPING[@blueprint.byte_length][s_key]
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::BuiltIn, Cauterize::Builders::CS::BuiltIn)
