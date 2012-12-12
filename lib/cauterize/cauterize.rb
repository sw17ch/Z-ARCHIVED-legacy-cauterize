require "require_all"

lib_path = File.dirname(__FILE__) + "/.."
require_all Dir[lib_path + "/**/*.rb"]

module Cauterize
  def self.generate_c(target_dir, desc_file)
    Object.new.extend(Cauterize).instance_eval(File.read(desc_file))
    output_prefix = @name || "cauterize"

    FileUtils.mkdir_p(target_dir)
    h_file = File.join(target_dir, "#{output_prefix}.h")
    c_file = File.join(target_dir, "#{output_prefix}.c")

    builder = Cauterize::CBuilder.new(h_file, c_file, output_prefix)
    builder.build
  end
end
