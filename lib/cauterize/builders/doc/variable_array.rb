module Cauterize
  module Builders
    module Doc
      class VariableArray < Buildable
        def heading
          [
            "Type Name: #{@blueprint.name}",
            "Cauterize Class: variable-array",
            "Description: #{@blueprint.description ? @blueprint.description : "<none>"}",
            "Maximum Value Count: #{@blueprint.array_size}",
          ].join("\n")
        end

        def body
          [
            "length - type #{@blueprint.size_type.name}",
            "data - 0 to #{@blueprint.array_size} values of type #{@blueprint.array_type.name}",
          ]
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::VariableArray, Cauterize::Builders::Doc::VariableArray)

