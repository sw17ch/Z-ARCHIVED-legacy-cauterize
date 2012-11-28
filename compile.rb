#!/usr/bin/env ruby

$LOAD_PATH.unshift("./rb")

require 'yaml'
require 'require_all'
require_all Dir[File.dirname(__FILE__) + '/rb/lib/**/*.rb']

def validate(hash, *keys)
  h_keys = hash.keys
  unless keys == keys & h_keys
    raise "Missing keys: #{(keys - h_keys).join(", ")}."
  end
end

def compile_files(*files)
  definitions = files.map do |f|
    begin
      YAML.load(File.read(f))
    rescue Exception => e
      $stderr.puts "Unable to parse file: #{f}."
      raise e
    end
  end.reduce {|a,b| a.concat b}

  h_messages = definitions.find_all {|d| d["message"]}
  messages = h_messages.map do |m|
    begin
      Message.from_hash(m)
    rescue Exception => e
      $stderr.puts "Not a message: #{m}."
      raise e
    end
  end

  h_groups = definitions.find_all {|d| d["group"]}
  groups = h_groups.map do |g|
    begin
      Group.from_hash(g)
    rescue Exception => e
      $stderr.puts "Not a group: #{g}."
      raise e
    end
  end

  c = CFormatter.new("cauterize_example")

  messages.each { |req| req.format_struct(c) }
  groups.each { |grp| grp.format_enumeration(c) }
  groups.each { |grp| grp.format_struct(c) }
  groups.each { |grp| grp.format_packer(c) }
  groups.each { |grp| grp.format_unpacker(c) }

  puts c.c_text
end

compile_files(*ARGV)
