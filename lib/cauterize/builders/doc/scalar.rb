module Cauterize
  module Builders
    module Doc
      class Scalar < Buildable
        def heading
          [
            "Type Name: #{@blueprint.name}",
            "Cauterize Class: scalar",
            "Description: #{(@blueprint.description ? " - #{@blueprint.description}" : "<none>")}",
          ].join("\n")
        end

        def body
          ["data - type: #{@blueprint.type_name.name}"]
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::Scalar, Cauterize::Builders::Doc::Scalar)
