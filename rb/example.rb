#!/usr/bin/env ruby

require 'require_all'
require_all Dir['lib/**/*.rb']

def var_byte_array(len)
  sym = "var_byte_array_#{len}".to_sym
  composite sym do |c|
    c.field :length, :uint32_t
    c.field :bytes, :uint8_t do |f|
      f.count = len.to_i
    end

    # The number of valid bytes in `:bytes` is defined by `:length`
    c.size_map :bytes, :length
  end
end

def byte_array(len)
  sym = "byte_array_#{len}".to_sym
  composite sym do |c|
    c.field :length, :uint32_t
    c.field :bytes, :uint8_t do |f|
      f.count = len.to_i
    end
  end
end

atom :uint8_t
atom :uint16_t
atom :uint32_t
atom :uint64_t

var_byte_array(32)
var_byte_array(128)

composite :user_lookup do |c|
  c.field :id, :uint32_t
end

composite :user_data do |c|
  c.field :id, :uint32_t
  c.field :name, :var_byte_array_32
end

composite :user_create do |c|
  c.field :name, :var_byte_array_32
end

composite :user_create_status do |c|
  c.field :id, :uint32_t
  c.field :name, :var_byte_array_32
end

group :request do |g|
  g.member :user_lookup, :user_lookup
  g.member :user_create, :user_create
end

group :response do |g|
  g.member :user_data, :user_data
  g.member :user_create_status, :user_create_status
end

build "user_data"
