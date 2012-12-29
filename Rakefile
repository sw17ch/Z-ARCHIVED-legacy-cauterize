require 'tmpdir'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :default => :greatest

desc "Run C tests"
task :greatest do
  Dir.mktmpdir do |d|
    test_suite_path = File.join(d, "test_suite.c")
    mk_test_suite_file(test_suite_path)

    args = "-Wall -Wextra -Werror -Ic/test -Ic/src -I#{d}"
    srcs = "c/src/cauterize.c c/test/test.c"
    bin = File.join(d, "test.bin")
    sh "gcc #{args} #{srcs} -o #{bin}"
    sh bin
  end
end

# Support Methods

SUITE_ENTRY_TEMPLATE = "  RUN_TEST(%s);"

def mk_test_suite_file(path)
  test_files = Dir["c/test/*.c"]
  suite_text = test_files.map do |test_file|
    File.read(test_file).lines.map do |l|
      m = l.match(/^TEST (?<sym>[^\(]+)\(\)/)
      m ? m[:sym] : nil
    end.compact
  end.flatten.map {|t| SUITE_ENTRY_TEMPLATE % t}.join("\n") + "\n"

  File.open(path, "wb") {|fh| fh.write(suite_text)}
end
