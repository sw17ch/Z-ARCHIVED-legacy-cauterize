module Cauterize
  module Builders
    module Doc
      class FixedArray < Buildable
        def heading
          [
            "Type Name: #{@blueprint.name}",
            "Cauterize Class: fixed-array",
            "Description: #{@blueprint.description ? @blueprint.description : "<none>"}",
            "Stored Type: #{@blueprint.array_type.name}",
            "Value Count: #{@blueprint.array_size}",
          ].join("\n")
        end

        def body
          [
            "data - #{@blueprint.array_size} values of type #{@blueprint.array_type.name}",
          ]
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::FixedArray, Cauterize::Builders::Doc::FixedArray)

