require "require_all"

lib_path = File.dirname(__FILE__) + "/.."
require_all Dir[lib_path + "/**/*.rb"]

module Cauterize
  # Genearte the C code corresponding to the generated configuration
  def self.generate_c(target_dir, desc_file)
    Object.new.extend(Cauterize).instance_eval(File.read(desc_file))
    output_prefix = get_name || "generated_interface"

    FileUtils.mkdir_p(target_dir)
    h_file = File.join(target_dir, "#{output_prefix}.h")
    c_file = File.join(target_dir, "#{output_prefix}.c")

    builder = Cauterize::CBuilder.new(h_file, c_file, output_prefix)
    builder.build
  end

  def self.get_name
    @@description_name
  end

  def set_name(desc_name)
    @@description_name = desc_name
  end
end
