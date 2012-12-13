require 'tmpdir'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :default => :greatest

task :greatest do
  Dir.mktmpdir do |d|
    args = "-Wall -Wextra -Werror -Ic/test -Ic/src"
    srcs = "c/test/test.c c/src/cauterize.c"
    bin = File.join(d, "test.bin")
    sh "gcc #{args} #{srcs} -o #{bin}"
    sh bin
  end
end


