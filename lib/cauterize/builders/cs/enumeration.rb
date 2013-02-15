module Cauterize::Builders::CS
  class Enumeration < Buildable
    def enum_defn(formatter)
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

Cauterize::Builders.register(:cs, Cauterize::Enumeration, Cauterize::Builders::CS::Enumeration)
