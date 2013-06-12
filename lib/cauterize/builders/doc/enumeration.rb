module Cauterize
  module Builders
    module Doc
      class Enumeration < Buildable
        def heading
          [
            "Type Name: #{@blueprint.name}",
            "Cauterize Class: enumeration",
            "Description: #{@blueprint.description ? @blueprint.description : "<none>"}",
            "Encoding: #{@blueprint.representation.name}",
          ].join("\n")
        end

        def body
          @blueprint.values.values.map {|v| "  #{v.name} = #{v.value}"}
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::Enumeration, Cauterize::Builders::Doc::Enumeration)


