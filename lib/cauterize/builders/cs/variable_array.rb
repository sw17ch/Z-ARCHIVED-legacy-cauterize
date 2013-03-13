module Cauterize::Builders::CS
  class VariableArray < CSArray

    def render_parent
      "CauterizeVariableArrayTyped<#{ty_bldr.render}>"
    end

    def simple_constructor_line
      "public #{render}(int size)"
    end

    def size_defn(formatter)
      formatter << "protected override int MaxSize"
      formatter.braces do
        formatter << "get { return #{size_type}.MaxValue; }"
      end
    end

    def size
      return "size"
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
