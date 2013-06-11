module Cauterize
  class DocBuilder
    attr_reader :doc_path, :name
    def initialize(doc_path, name="cauterize")
      @doc_path = doc_path
      @name = name
    end

    def build
      build_doc
    end

    private

    def build_doc
      File.open(@doc_path, "wb") do |fh|
        doc_sections = []

        instances = BaseType.all_instances
        builders = instances.map {|i| Builders.get(:doc, i)}

        builders.each do |b|
          body_lines = (b.body || []).map {|l| "  " + l}
          lines = ([b.heading] + body_lines)

          doc_sections << lines.join("\n")
        end

        fh.write(doc_sections.join("\n"))
      end
    end
  end
end

