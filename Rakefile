require 'rake/testtask'

Rake::TestTask.new do |t|
   t.libs << 'test'
   t.test_files = FileList['test/tsubaiso_sdk/test_*.rb', 'test/test_*.rb']
   t.verbose = true
end

desc 'Run tests'
task :default => :test