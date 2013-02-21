module Cauterize::Builders::CS
  class VariableArray < CSArray

    def render_parent
      "CauterizeVariableArray"
    end

    def constructor_defn(formatter)
      formatter << "public #{render}(int size)"
      formatter.braces do
        size_guard(formatter,"size")
        formatter << "_data = new #{ty_bldr.render}[size];"
      end

      formatter.blank_line
      formatter << "public #{render}(#{ty_bldr.render}[] data)"
      formatter.braces do
        size_guard(formatter, "data.Length")
        formatter << "_data = new #{ty_bldr.render}[data.Length];"
        formatter << "Array.Copy(data,_data,data.Length);"
      end
    end

    def size_guard(formatter, size_exp)
      formatter << "if (#{size_exp} >= #{size_type}.MaxValue)"
      formatter.braces do
        formatter << "throw new CauterizeException(\"arrays for #{render} must be smaller than\" + #{size_type}.MaxValue);"
      end
    end

    protected
    def extra_array_declarations(formatter)
      formatter << "public static Type SizeType = typeof(#{size_type});"
    end

    def size_type
      Cauterize::Builders.get(:cs, @blueprint.size_type).render
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::VariableArray, Cauterize::Builders::CS::VariableArray)
