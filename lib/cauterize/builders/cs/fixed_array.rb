module Cauterize::Builders::CS
  class FixedArray < CSArray

    def render_parent
      "CauterizeFixedArray"
    end

    def constructor_defn(formatter)
      formatter << "public #{render}()"
      formatter.braces do
        formatter << "_data = new #{ty_bldr.render}[#{size}];"
      end
      formatter.blank_line
      formatter << "public #{render}(#{ty_bldr.render}[] data)"
      formatter.braces do
        formatter << "if (data.Length != #{size})"
        formatter.braces do
          formatter << "throw new CauterizeException(\"arrays for #{render} must be exactly size #{size}\");"
        end
        formatter << "_data = new #{ty_bldr.render}[#{size}];"
        formatter << "Array.Copy(data,_data,#{size});"
      end
    end

    def size
      @blueprint.array_size
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::FixedArray, Cauterize::Builders::CS::FixedArray)
