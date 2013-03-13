module Cauterize::Builders::CS
  class CSArray < Buildable
    def class_defn(formatter)
      formatter << "public class #{render} : #{render_parent}"
      formatter.braces do
        extra_array_declarations(formatter)
        formatter.blank_line
        formatter << simple_constructor_line
        formatter.braces do
          formatter << "Allocate(#{size});"
        end
        formatter.blank_line
        formatter << "public #{render}(#{ty_bldr.render}[] data)"
        formatter.braces do
          formatter << "Allocate(data);"
        end
        formatter.blank_line
        size_defn(formatter)
      end
      formatter.blank_line
    end

    protected

    def extra_array_declarations(formatter)
    end

    def ty_bldr
      @ty_bldr ||= Cauterize::Builders.get(:cs, @blueprint.array_type)
    end
  end
end
