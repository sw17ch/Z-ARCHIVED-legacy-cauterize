module Cauterize::Builders::CS
  class BuiltIn < Buildable
    @@CS_TYPE_MAPPING = {
      1 => {signed: "SByte", unsigned: "Byte",   :float => nil,      :bool => "bool"},
      2 => {signed: "Int16", unsigned: "UInt16", :float => nil,      :bool => nil},
      4 => {signed: "Int32", unsigned: "UInt32", :float => "Single",  :bool => nil},
      8 => {signed: "Int64", unsigned: "UInt64", :float => "Double", :bool => nil},
    }

    def render
      render_cstype
    end

    private

    def render_cstype
      @@CS_TYPE_MAPPING[@blueprint.byte_length][@blueprint.flavor]
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::BuiltIn, Cauterize::Builders::CS::BuiltIn)
