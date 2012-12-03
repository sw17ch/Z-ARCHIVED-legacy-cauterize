class CFunction
  # `params` is an array of strings suitable as parameter declarations.
  def initialize(name, ret, params)
    @name = name
    @ret = ret
    @params = params
  end

  def prototype(formatter)
    formatter << proto_string + ";"
  end

  def definition(formatter)
    formatter << proto_string
    formatter.braces do
      if block_given?
        yield formatter
      end
    end
  end

  private

  def proto_string
    "#{@ret} #{@name}(#{@params.join(", ")})"
  end
end
