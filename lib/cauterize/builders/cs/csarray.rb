module Cauterize::Builders::CS
  class CSArray < Buildable
    def class_defn(formatter)
      formatter << "public class #{render} : #{render_parent}"
      formatter.braces do
        formatter << "private #{ty_bldr.render}[] _data;"
        formatter.blank_line
        constructor_defn(formatter)
        formatter.blank_line
        formatter << "public #{ty_bldr.render} this[int i]"
        formatter.braces do
          formatter << "get { return _data[i]; }"
          formatter << "set { _data[i] = value; }"
        end
      end
      formatter.blank_line
    end

    protected

    def ty_bldr
      @ty_bldr ||= Cauterize::Builders.get(:cs, @blueprint.array_type)
    end
  end
end
