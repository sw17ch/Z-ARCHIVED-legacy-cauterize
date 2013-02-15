require 'time'

module Cauterize
  class CSBuilder
    attr_reader :cs

    def initialize(cs_file, name="cauterize")
      @cs = cs_file
      @name = name.camel
    end

    def build
      build_cs
    end

    private

    def build_cs
      f = four_space_formatter

      f << "using System;"
      f.blank_line
      f << "public class #{@name}CauterizeInfo : CauterizeInfo"
      f << "{"
      f << "    static #{@name}CauterizeInfo()"
      f << "    {"
      f << "        Name = \"#{@name}\";"
      f << "        GeneratedVersion = \"#{Cauterize.get_version}\";"
      f << "        GeneratedDate = \"#{Cauterize.get_version}\";"
      f << "    }"
      f << "}"
      f.blank_line

      instances = BaseType.all_instances
      builders = instances.map {|i| Builders.get(:cs, i)}

      builders.each { |b| b.enum_defn(f) }
      builders.each { |b| b.class_defn(f) }
      # # should we really do these, or is it annotations and a custom
      # # formatter in support???
      # builders.each { |b| b.packer_defn(f) }
      # builders.each { |b| b.unpacker_defn(f) }

      File.open(@cs, "wb") do |fh|
        fh.write(f.to_s)
      end
    end
  end
end
