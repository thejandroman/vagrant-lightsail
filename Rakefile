require 'bundler/gem_tasks'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

task :shell_test do
  result = sh 'bash test/test.sh'

  if result
    puts 'Success!'
  else
    puts 'Failure!'
    exit 1
  end
end

desc 'Run all tests: rubocop, shell_test'
task test: [:rubocop, :shell_test]

task default: :test
