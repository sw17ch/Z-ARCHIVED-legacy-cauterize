module Cauterize::Builders::CS
  class CSArray < Buildable
    def class_defn(formatter)
      formatter << "public class #{render} : #{render_parent}"
      formatter.braces do
        extra_array_declarations(formatter)
        formatter << "private #{ty_bldr.render}[] _data;"
        formatter.blank_line
        constructor_defn(formatter)
        formatter.blank_line
        formatter << "public #{ty_bldr.render} this[int i]"
        formatter.braces do
          formatter << "get { return _data[i]; }"
          formatter << "set { _data[i] = value; }"
        end
        formatter.blank_line
        formatter << "public #{ty_bldr.render}[] this[Tuple<int, int> range]"
        formatter.braces do
          formatter << "get { return _data.Skip(range.Item1).Take(range.Item2-range.Item1).ToArray(); }"
          formatter << "set { Array.ConstrainedCopy(value, 0, _data, range.Item1, range.Item2 - range.Item1); }"
        end
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
