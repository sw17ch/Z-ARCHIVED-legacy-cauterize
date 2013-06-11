module Cauterize
  module Builders
    module Doc
      class Enumeration < Buildable
        def heading
          "enumeration #{@blueprint.name}" + (@blueprint.description ? " - #{@blueprint.description}" : "")
        end

        def body
          [
            "encoded as type #{@blueprint.representation.name}",
            "values:",
          ] + @blueprint.values.values.map {|v| "  #{v.name} = #{v.value}"}
        end
      end
    end
  end
end

Cauterize::Builders.register(:doc, Cauterize::Enumeration, Cauterize::Builders::Doc::Enumeration)


