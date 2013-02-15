module Cauterize::Builders::CS
  class Group < Buildable
    def initialize(blueprint)
      super(blueprint)
      @tag_enum = blueprint.tag_enum
    end

    def class_defn(formatter)
      formatter << "public class #{render}"
      formatter.braces do
        Cauterize::Builders.get(:cs, @tag_enum).declare(formatter, "Type")
        formatter.blank_line
        @blueprint.fields.values.each do |field|
          b = Cauterize::Builders.get(:cs, field.type)
          if b
            b.declare(formatter, field.name)
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
