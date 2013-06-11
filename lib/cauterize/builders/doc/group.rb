module Cauterize
  module Builders
    module Doc
      class Group < Buildable
        def heading
          "group #{@blueprint.name}" + (@blueprint.description ? " - #{@blueprint.description}" : "")
        end

        def body
          vals = @blueprint.fields.values.map do |v|
            "  #{v.name} - #{v.type ? v.type.name : "<none>"}" + (v.description ? " - #{v.description}" : "")
          end

          [
            "representation encoded as enumeration #{@blueprint.tag_enum.name}",
            "representations:"
          ] + vals
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::Group, Cauterize::Builders::Doc::Group)

