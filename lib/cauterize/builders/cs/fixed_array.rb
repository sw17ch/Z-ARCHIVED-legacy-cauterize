module Cauterize::Builders::CS
  class FixedArray < CSArray

    def constructor_defn(formatter)
      formatter << "public #{render}()"
      formatter.braces do
        formatter << "_data = new #{ty_bldr.render}[#{@blueprint.array_size}];"
      end
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::FixedArray, Cauterize::Builders::CS::FixedArray)
