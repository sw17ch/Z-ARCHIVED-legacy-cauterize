module Cauterize
  module Builders
    module Doc
      class Group < Buildable
        def heading
          [
            "Type Name: #{@blueprint.name}",
            "Cauterize Class: group",
            "Description: #{(@blueprint.description ? " - #{@blueprint.description}" : "<none>")}",
          ].join("\n")
        end

        def body
          vals = @blueprint.fields.values.map do |v|
            "  #{v.name} - payload: #{v.type ? v.type.name : "<no payload>"}" + (v.description ? " - description: #{v.description}" : "")
          end

          [
            "kind tag: #{@blueprint.tag_enum.name}",
            "kinds:"
          ] + vals
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::Group, Cauterize::Builders::Doc::Group)

