class Enum
  @@enums = {}
  def self.enums; @@enums end
  def self.find(e); @@enums[e] end
  def self.create(name)
    @@enums[name] = Enum.new(name)
  end

  def initialize(name)
    @name = name
    @values = {}

    yield self if block_given?
  end
end
