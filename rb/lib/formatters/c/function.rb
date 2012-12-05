class CFunction
  # `params` is an array of strings suitable as parameter declarations.
  def initialize(name, ret, params, &blk)
    @name = name
    @ret = ret
    @params = params
    @defn_blk = blk
  end

  def prototype(formatter)
    formatter << proto_string + ";"
  end

  def definition(formatter)
    formatter << proto_string
    formatter.braces do
      blk.call(formatter) if blk
      formatter << "#{@ret};"
    end
    formatter.blank_line
  end

  private

  def proto_string
    "#{@ret} #{@name}(#{@params.join(", ")})"
  end
end
