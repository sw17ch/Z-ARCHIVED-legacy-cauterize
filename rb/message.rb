class Message
  attr_reader :fields

  def self.from_hash(hash)
    validate(hash, "message")
    message = hash["message"]
    validate(message, "fields")

    fields = message["fields"].map {|f| Field.from_hash(f)}
    Message.new(message["name"], fields)
  end

  def initialize(name, fields)
    @name = name
    @fields = fields
  end

  def format(formatter)
    formatter.struct(@name) do |f|
      fields.each {|field| field.format(f)}
    end
    formatter.blank_line
  end

  def marshaler(formatter)
    raise :unimplemented
  end

  def unmarshaler(formatter)
    raise :unimplemented
  end
end

