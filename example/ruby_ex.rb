$LOAD_PATH << File.join(File.dirname(__FILE__), "../lib")
require 'cauterize'
require 'bindata'


Cauterize.populate(ARGV[0])

i = Cauterize::ExampleProject::Wat.new
i.tag.representation = 0
p i.num_bytes
i.tag.representation = 1
p i.num_bytes
i.tag.representation = 2
p i.num_bytes
