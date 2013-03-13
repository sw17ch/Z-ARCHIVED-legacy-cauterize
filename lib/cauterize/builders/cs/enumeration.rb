module Cauterize
  module Builders
    module CS
      class Enumeration < Buildable
        def enum_defn(formatter)
          rep_builder = Builders.get(:cs, @blueprint.representation)
          formatter << "[SerializedRepresentation(typeof(#{rep_builder.render}))]"
          formatter << "public enum #{render}"
          formatter.braces do
            @blueprint.values.values.each do |v|
              formatter << "#{v.name.to_s.camel} = #{v.value},"
            end
          end
          formatter.append(";")
        end
      end
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::Enumeration, Cauterize::Builders::CS::Enumeration)
