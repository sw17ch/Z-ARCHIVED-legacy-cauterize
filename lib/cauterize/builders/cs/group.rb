module Cauterize::Builders::CS
  class Group < Buildable
    def initialize(blueprint)
      super(blueprint)
      @tag_enum = blueprint.tag_enum
    end

    def render_parent
      "CauterizeGroup"
    end

    def class_defn(formatter)
      formatter << "public class #{render} : #{render_parent}"
      formatter.braces do
        formatter << "[Order(0)]"
        Cauterize::Builders.get(:cs, @tag_enum).declare(formatter, "Type")
        formatter.blank_line
        @blueprint.fields.values.each_with_index do |field, i|
          if field.type
            formatter << "[Order(#{i+1})]"
            Cauterize::Builders.get(:cs, field.type).declare(formatter, field.name)
          else
            formatter << "/* No data associated with '#{field.name}'. */"
          end
        end
      end
      formatter.blank_line
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::Group, Cauterize::Builders::CS::Group)
