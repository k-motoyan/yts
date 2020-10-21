require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

task :serve do
  system "bin/yts convert > doc/swagger.json"
  system "bin/yts document -i doc/swagger.json"
  system "bin/yts serve -s doc/swagger.html"
end