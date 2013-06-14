$LOAD_PATH << File.join(File.dirname(__FILE__), "../lib")
require 'cauterize'
require 'bindata'


Cauterize.populate(ARGV[0])

p BinData::RegisteredClasses

p Cauterize::ExampleProject::Color.new.enum
