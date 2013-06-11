module Cauterize
  module Builders
    module Doc
      class Composite < Buildable
        def heading
          "composite #{@blueprint.name}" + (@blueprint.description ? " - #{@blueprint.description}" : "")
        end

        def body
          @blueprint.fields.values.map do |v|
            "#{v.name} - #{v.type.name}" + (v.description ? " - #{v.description}" : "")
          end
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::Composite, Cauterize::Builders::Doc::Composite)
