require 'securerandom'

def find_type(type)
  Composite.find(type) or Atom.find(type)
end

def find_type!(type)
  t = find_type(type)
  raise Exception.new("Undefined type: #{type}") unless t
  return t
end

def check_type(type)
  raise Exception.new("Type #{type} already defined") if find_type(type)
end

def interp(pat, *vars)
  vars.inject(pat) {|memo, rep| memo.sub("?", rep)}
end

def atom(name)
  a = Atom.create(name)
  yield a if block_given?
end

def composite(name)
  c = Composite.create(name)
  yield c if block_given?
end

def group(name)
  g = Group.create(name)
  yield g if block_given?
end

def build_h(name, guard = SecureRandom.uuid.gsub('-','_'))
  f = Formatter.new

  composite = name + "_" + guard

  f << "#ifndef #{composite}"
  f << "#define #{composite}"
  f.blank_line
  f << "#include <cauterize.h>"
  f.blank_line
  Composite.composites.each_pair do |name, defn|
    defn.prototype(f)
  end
  Composite.composites.each_pair do |name, defn|
    f.blank_line
    defn.definition(f)
  end
  f.blank_line
  Atom.atoms.each_pair do |name, defn|
    f.blank_line
    defn.packer_prototype(f)
    defn.unpacker_prototype(f)
  end
  Composite.composites.each_pair do |name, defn|
    f.blank_line
    defn.packer_prototype(f)
    defn.unpacker_prototype(f)
  end
  f.blank_line
  Group.groups.each_pair do |name, defn|
    defn.prototype(f)
  end
  Group.groups.each_pair do |name, defn|
    f.blank_line
    defn.enum_definition(f)
    defn.definition(f)
    defn.packer_prototype(f)
    defn.unpacker_prototype(f)
  end
  f << "#endif /* #{composite} */"
  f.blank_line

  File.open("#{name}.h", "wb") {|fh| fh.write(f.to_s)}
end

def build_c(name)
  f = Formatter.new

  f << "#include <cauterize.h>"
  f << "#include <#{name}.h>"

  Atom.atoms.each_pair do |name, defn|
    f.blank_line
    defn.packer_declaration(f)
    defn.unpacker_declaration(f)
  end
  Composite.composites.each_pair do |name, defn|
    f.blank_line
    defn.packer_declaration(f)
    defn.unpacker_declaration(f)
  end
  Group.groups.each_pair do |name, defn|
    f.blank_line
    defn.packer_definition(f)
    # defn.unpacker_definition(f)
  end

  File.open("#{name}.c", "wb") {|fh| fh.write(f.to_s)}
end

def build(name)
  build_h(name)
  build_c(name)
end
