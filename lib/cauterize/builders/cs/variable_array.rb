module Cauterize::Builders::CS
  class VariableArray < CSArray

    def constructor_defn(formatter)
      formatter << "public #{render}(int size)"
      formatter.braces do
        formatter << "_data = new #{ty_bldr.render}[size];"
      end
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::VariableArray, Cauterize::Builders::CS::VariableArray)
