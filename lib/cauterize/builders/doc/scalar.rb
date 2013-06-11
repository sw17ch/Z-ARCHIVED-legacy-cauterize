module Cauterize
  module Builders
    module Doc
      class Scalar < Buildable
        def heading
          "scalar #{@blueprint.name} - #{@blueprint.type_name.name}" + (@blueprint.description ? " - #{@blueprint.description}" : "")
        end

        def body; nil end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::Scalar, Cauterize::Builders::Doc::Scalar)
