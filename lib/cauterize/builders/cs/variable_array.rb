module Cauterize::Builders::CS
  class VariableArray < CSArray

    def render_parent
      "CauterizeVariableArray"
    end

    def constructor_defn(formatter)
      formatter << "public #{render}(int size)"
      formatter.braces do
        formatter << "_data = new #{ty_bldr.render}[size];"
      end
    end

    protected
    def extra_array_declarations(formatter)
      size_type = Cauterize::Builders.get(:cs, @blueprint.size_type).render
      formatter << "public static Type SizeType = typeof(#{size_type});"
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::VariableArray, Cauterize::Builders::CS::VariableArray)
