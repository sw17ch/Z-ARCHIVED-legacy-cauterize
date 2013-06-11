module Cauterize
  module Builders
    module Doc
      class BuiltIn < Buildable
        def heading
          "builtin #{@blueprint.name}" + (@blueprint.description ? " - #{@blueprint.description}" : "")
        end

        def body; nil end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::BuiltIn, Cauterize::Builders::Doc::BuiltIn)
