module Cauterize::Builders::CS
  class Composite < Buildable
    def class_defn(formatter)
      formatter << "public class #{render}"
      formatter.braces do
        @blueprint.fields.values.each do |field|
          Cauterize::Builders.get(:cs, field.type).declare(formatter, field.name)
        end
      end
      formatter.blank_line
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::Composite, Cauterize::Builders::CS::Composite)
