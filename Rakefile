require "rubygems"
require "bundler"
Bundler.setup

require 'rake'
require 'rdoc/task'
require 'rspec/core/rake_task'

desc "Default Task"
task :default => [ :spec ]

# run all rspecs
desc "Run all rspec files"
RSpec::Core::RakeTask.new("spec") do |t|
  t.rspec_opts = ["--color", "--format progress"]
  t.ruby_opts = "-w"
end

# Genereate the RDoc documentation
desc "Create documentation"
RDoc::Task.new do |rdoc|
  rdoc.title = "em-ftpd"
  rdoc.rdoc_dir = (ENV['CC_BUILD_ARTIFACTS'] || 'doc') + '/rdoc'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('TODO')
  rdoc.rdoc_files.include('CHANGELOG')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options << "--inline-source"
end