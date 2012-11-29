class Message
  attr_reader :name, :fields

  def self.from_hash(hash)
    validate(hash, "message")
    message = hash["message"]
    validate(message, "fields", "name")

    fields = message["fields"].map {|f| Field.from_hash(f)}
    Message.new(message["name"], fields)
  end

  def initialize(name, fields)
    @name = name
    @fields = fields
  end

  def format_struct(formatter)
    formatter.struct(@name) do |f|
      fields.each {|field| field.format(f)}
    end
    formatter.blank_line
  end

  def format_packer(formatter)
    raise :unimplemented
  end

  def format_unpacker(formatter)
    raise :unimplemented
  end
end

