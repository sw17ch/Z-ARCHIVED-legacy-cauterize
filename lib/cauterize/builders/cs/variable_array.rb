module Cauterize::Builders::CS
  class VariableArray < CSArray

    def render_parent
      "CauterizeVariableArrayTyped<#{ty_bldr.render}>"
    end

    def simple_constructor_line
      "public #{render}(ulong size)"
    end

    def size_defn(formatter)
      formatter << "public static ulong MyMaxSize = #{max_size};"
      formatter.blank_line
      formatter << "protected override ulong MaxSize"
      formatter.braces do
        formatter << "get { return MyMaxSize; }"
      end
    end

    def max_size
      @blueprint.array_size
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
