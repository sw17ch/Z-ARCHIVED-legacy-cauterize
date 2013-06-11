module Cauterize
  module Builders
    module Doc
      class VariableArray < Buildable
        def heading
          "variable_array #{@blueprint.name}" + (@blueprint.description ? " - #{@blueprint.description}" : "")
        end

        def body
          [
            "length: length of data is encoded as type #{@blueprint.size_type.name}",
            "data: up to #{@blueprint.array_size} values of type #{@blueprint.array_type.name}",
          ]
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::VariableArray, Cauterize::Builders::Doc::VariableArray)

