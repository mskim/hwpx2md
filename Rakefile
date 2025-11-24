require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/test_*.rb']
end

desc 'Run tests.'
task default: :test

desc "Open an irb session preloaded with this library."
task :console do
  sh "irb -I lib/ -r hwpx2md"
end
