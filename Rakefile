require 'rake'
require 'rake/rdoctask'
require 'rcov/rcovtask'


begin
  require 'spec/rake/spectask'
rescue LoadError
  puts 'To use rspec for testing you must install rspec gem:'
  puts '$ sudo gem install rspec'
  exit
end

desc "Default task is to run specs"
task :default => :show_all_tasks

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ['--options', '"spec/spec.opts"']
  # rcov
  t.rcov = true
  t.rcov_dir = 'doc/coverage'
  t.rcov_opts = ['-p', '-T', '--exclude', 'spec']
end

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--diff', '--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Print Specdoc for all specs"
Spec::Rake::SpecTask.new('specdoc') do |t|
  t.spec_opts = ["--format", "specdoc", "--dry-run", "--options", 'spec/spec.opts']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README.rdoc' << '--charset' << 'utf-8'
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include 'README.rdoc'
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :show_all_tasks do
  system "rake -T"
end
