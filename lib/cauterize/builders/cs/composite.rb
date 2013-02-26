module Cauterize::Builders::CS
  class Composite < Buildable

    def render_parent
      "CauterizeComposite"
    end

    def class_defn(formatter)
      formatter << "public class #{render} : #{render_parent}"
      formatter.braces do
        @blueprint.fields.values.each_with_index do |field, i|
          formatter << "[Order(#{i})]"
          Cauterize::Builders.get(:cs, field.type).declare(formatter, field.name)
        end
      end
      formatter.blank_line
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::Composite, Cauterize::Builders::CS::Composite)
