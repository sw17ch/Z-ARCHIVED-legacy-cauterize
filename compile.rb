#!/usr/bin/env ruby

$LOAD_PATH.unshift("./rb")

require 'yaml'
require 'c_formatter'

def validate(hash, *keys)
  h_keys = hash.keys
  unless keys == keys & h_keys
    raise "Missing keys: #{(keys - h_keys).join(", ")}."
  end
end

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

class Field
  def self.from_hash(hash)
    validate(hash, "name", "type", "init", "description")
    Field.new(hash["name"], hash["type"], hash["init"], hash["description"])
  end

  def initialize(name, type, init, description)
    @name = name
    @type = Type.parse(type)
    @init = init
    @desc = description
  end

  def format(formatter)
    formatter << "/* #{@desc} */"
    formatter << "#{@type.type_str} #{@name}#{@type.array_str};"
  end
end

class Type
  def self.parse(str)
    m = str.match(/(?<base>[^\[]+)(?:\[(?<array>[^\]]+)\])?/)
    hash = Hash[ m.names.zip( m.captures ) ]
    validate(hash, "base", "array")
    array = hash["array"] ? hash["array"] : nil
    Type.new(hash["base"], array)
  end

  def initialize(type, array_size=nil)
    @type = type
    @size = array_size
  end

  def type_str
    @type
  end

  def array_str
    if @size
      "[#{@size}]"
    else
      ""
    end
  end
end


def compile_files(*files)
  c = CFormatter.new
  messages = files.map do |f|
    begin
      YAML.load(File.read(f)).map {|h| Message.from_hash(h) }
    rescue Exception => e
      $stderr.puts "Failed to compile file: #{f}."
      raise e
    end
  end.reduce {|a,b| a.concat b}

  messages.each { |req| req.format(c) }

  puts c.to_s
end

compile_files(*ARGV)
