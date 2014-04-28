module Cauterize::Builders::CS
  class FixedArray < CSArray

    def render_parent
      "CauterizeFixedArrayTyped<#{ty_bldr.render}>"
    end

    def simple_constructor_line
      "public #{render}()"
    end

    def size_defn(formatter)
      formatter << "public static int MySize = #{size};"
      formatter.blank_line
      formatter << "protected override int Size"
      formatter.braces do
        formatter << "get { return MySize; }"
      end
    end

    def size
      @blueprint.array_size
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::FixedArray, Cauterize::Builders::CS::FixedArray)
