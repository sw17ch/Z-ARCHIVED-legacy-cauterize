module Cauterize
  module Builders
    module Doc
      class BuiltIn < Buildable
        def heading
          [
            "Type Name: #{@blueprint.name}",
            "Cauterize Class: built-in",
            "Description: #{(@blueprint.description ? " - #{@blueprint.description}" : "<none>")}",
          ].join("\n")
        end

        def body
          ["data - size: #{@blueprint.byte_length} bytes"]
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::BuiltIn, Cauterize::Builders::Doc::BuiltIn)
