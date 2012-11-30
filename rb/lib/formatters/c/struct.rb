class CStruct
  attr_reader :name, :fields

  def initialize(name, fields)
    @name = name
    @fields = fields
  end

  def prototype(formatter)
    formatter << "struct #{@name};"
  end

  def definition(formatter)
    formatter << "struct #{@name}"
    formatter.braces do
      @fields.each do |f|
        f.format(formatter)
      end
    end
    formatter.append(";")
    formatter.blankline
  end
end
