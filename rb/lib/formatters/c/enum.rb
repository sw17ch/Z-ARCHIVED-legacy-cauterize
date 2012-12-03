class CEnum
  def initialize(name, members)
    @name = name
    @members = members
  end

  def prototype(formatter)
    raise "No prototype for #{self.class.name}."
  end

  def definition(formatter)
    formatter << "enum #{@name}"
    formatter.braces do
      @members.each {|m| formatter << "#{m},"}
    end
    formatter.blank_line
  end
end
