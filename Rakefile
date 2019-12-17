require 'rake/testtask'

Rake::TestTask.new do |t|
   t.libs << 'test'
   t.test_files = FileList['test/tsubaiso_sdk/test_journal.rb']
end

desc 'Run tests'
task :default => :test