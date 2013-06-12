module Cauterize
  module Builders
    module Doc
      class Composite < Buildable
        def heading
          [
            "Type Name: #{@blueprint.name}",
            "Cauterize Class: composite",
            "Description: #{(@blueprint.description ? @blueprint.description : "<none>")}",
          ].join("\n")
        end

        def body
          @blueprint.fields.values.map do |v|
            "#{v.name} - type: #{v.type.name}" + (v.description ? " - description: #{v.description}" : "")
          end
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::Composite, Cauterize::Builders::Doc::Composite)
