# atom.rb
#
# Atoms are types that, in C, can be updated with assignment. This includes
# native types in C and typedefs around these native types.
#
# Atoms are not structs, enumerations, unions, or arrays.

module Cauterize
  def atom(name)
    a = atoms[name] || atoms[name] = Atom.new(name)
    yield a if block_given?
    return a
  end

  def atom!(name, &blk)
    if atoms[name]
      raise Exception.new("Atom with name #{name} already exists.")
    else
      atom(name, &blk)
    end
  end

  def atoms
    @atoms ||= {}
  end

  def flush_atoms
    @atoms = {}
  end

  class Atom < BaseType
    def initialize(name)
      super
    end
  end
end
