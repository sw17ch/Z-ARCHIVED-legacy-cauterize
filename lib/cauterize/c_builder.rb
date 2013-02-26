require 'time'

module Cauterize
  class CBuilder
    attr_reader :h, :c

    def initialize(h_file, c_file, name="cauterize")
      @h = h_file
      @c = c_file
      @name = name
    end

    def build
      build_h
      build_c
    end

    private

    def build_h
      f = default_formatter

      excluder = @name.up_snake + "_H_#{Time.now.to_i}"
      f << "#ifndef #{excluder}"
      f << "#define #{excluder}"
      f.blank_line
      f << %Q{#include <cauterize.h>}
      f.blank_line
      f << "#define GEN_VERSION (\"#{Cauterize.get_version}\")"
      f << "#define GEN_DATE (\"#{DateTime.now.to_s}\")"
      f.blank_line

      instances = BaseType.all_instances
      builders = instances.map {|i| Builders.get(:c, i)}

      builders.each { |b| b.typedef_decl(f) }
      builders.each { |b| b.enum_defn(f) }
      builders.each { |b| b.struct_proto(f) }
      builders.each { |b| b.struct_defn(f) }

      f << "#ifdef __cplusplus"
      f << "extern \"C\" {"
      f << "#endif"

      builders.each { |b| b.packer_proto(f) }
      builders.each { |b| b.unpacker_proto(f) }

      f << "#ifdef __cplusplus"
      f << "}"
      f << "#endif"

      f.blank_line
      f << "#endif /* #{excluder} */"

      File.open(@h, "wb") do |fh|
        fh.write(f.to_s)
      end
    end

    def build_c
      f = default_formatter

      f << %Q{#include <cauterize_util.h>}
      f << %Q{#include "#{@name}.h"}

      instances = BaseType.all_instances
      builders = instances.map {|i| Builders.get(:c, i)}

      builders.each { |b| b.packer_defn(f) }
      builders.each { |b| b.unpacker_defn(f) }

      File.open(@c, "wb") do |fh|
        fh.write(f.to_s)
      end
    end
  end
end
