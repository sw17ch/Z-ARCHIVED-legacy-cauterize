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

      excluder = @name.up_snake + "_H"
      f << "#ifndef #{excluder}"
      f << "#define #{excluder}"
      f.blank_line
      f << %Q{#include <cauterize.h>}
      f << %Q{#include <stdint.h>}
      f.blank_line

      BaseType.all_instances.each do |i|
        i.format_h_proto(f)
      end

      f.blank_line

      BaseType.all_instances.each do |i|
        i.format_h_defn(f)
      end

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

      BaseType.all_instances.each do |i|
        i.format_c_defn(f)
      end

      File.open(@c, "wb") do |fh|
        fh.write(f.to_s)
      end
    end
  end
end
