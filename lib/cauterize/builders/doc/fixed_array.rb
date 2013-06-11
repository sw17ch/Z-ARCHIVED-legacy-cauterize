module Cauterize
  module Builders
    module Doc
      class FixedArray < Buildable
        def heading
          "fixed_array #{@blueprint.name}" + (@blueprint.description ? " - #{@blueprint.description}" : "")
        end

        def body
          ["data: #{@blueprint.array_size} values of type #{@blueprint.array_type.name}"]
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::FixedArray, Cauterize::Builders::Doc::FixedArray)

