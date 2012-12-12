# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cauterize/version'

Gem::Specification.new do |gem|
  gem.name          = "cauterize"
  gem.version       = Cauterize::VERSION
  gem.authors       = ["John Van Enk"]
  gem.email         = ["vanenkj@gmail.com"]
  gem.summary       = %q{Tools to generate structures and mashalers suitable for static-memory environments.}
  gem.description   = %q{Tools to generate C structures and marshalers with a Ruby DSL.}
  gem.homepage      = "https://github.com/sw17ch/cauterize"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
