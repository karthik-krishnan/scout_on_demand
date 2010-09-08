# desc "Explaining what the task does"
# task :rspec_on_rails_hacks do
#   # Task goes here
# end

raise "To avoid rake task loading problems: run 'rake clobber' in vendor/plugins/rspec" if File.directory?(File.join(File.dirname(__FILE__), *%w[.. .. vendor plugins rspec pkg]))
raise "To avoid rake task loading problems: run 'rake clobber' in vendor/plugins/rspec-rails" if File.directory?(File.join(File.dirname(__FILE__), *%w[.. .. vendor plugins rspec-rails pkg]))

# In rails 1.2, plugins aren't available in the path until they're loaded.
# Check to see if the rspec plugin is installed first and require
# it if it is.  If not, use the gem version.
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../../rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)

require 'spec/rake/spectask'
require 'active_record'

spec_prereq = File.exist?(File.join(RAILS_ROOT, 'config', 'database.yml')) ? "db:test:prepare" : :noop

task :stats => "spec:stat_setup_with_presenters"

namespace :spec do

  desc "Run the specs under spec/presenters"
  Spec::Rake::SpecTask.new(:presenters => spec_prereq) do |t|
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList["spec/presenters/**/*_spec.rb"]
  end

  # Setup specs for stats
  task :stat_setup_with_presenters do
    require 'code_statistics'
    ::STATS_DIRECTORIES.clear 	
    ::CodeStatistics::TEST_TYPES.clear
    ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exists?("#{RAILS_ROOT}/spec/models")
    ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exists?("#{RAILS_ROOT}/spec/views")
    ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exists?("#{RAILS_ROOT}/spec/controllers")
    ::STATS_DIRECTORIES << %w(Presenter\ specs spec/presenters) if File.exists?("#{RAILS_ROOT}/spec/presenters")
    ::STATS_DIRECTORIES << %w(Helper\ specs spec/helpers) if File.exists?("#{RAILS_ROOT}/spec/helpers")
    ::STATS_DIRECTORIES << %w(Lib\ specs spec/lib) if File.exists?("#{RAILS_ROOT}/spec/lib")
    ::STATS_DIRECTORIES << %w(Watir\ specs spec/watir) if File.exists?("#{RAILS_ROOT}/spec/watir")
    ::CodeStatistics::TEST_TYPES << "Model specs" if File.exists?("#{RAILS_ROOT}/spec/models")
    ::CodeStatistics::TEST_TYPES << "View specs" if File.exists?("#{RAILS_ROOT}/spec/views")
    ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exists?("#{RAILS_ROOT}/spec/controllers")
    ::CodeStatistics::TEST_TYPES << "Presenter specs" if File.exists?("#{RAILS_ROOT}/spec/presenters")
    ::CodeStatistics::TEST_TYPES << "Helper specs" if File.exists?("#{RAILS_ROOT}/spec/helpers")
    ::CodeStatistics::TEST_TYPES << "Lib specs" if File.exists?("#{RAILS_ROOT}/spec/lib")
    ::CodeStatistics::TEST_TYPES << "Watir specs" if File.exists?("#{RAILS_ROOT}/spec/watir")
    ::STATS_DIRECTORIES.delete_if {|a| a[0] =~ /test/}
  end
  
  desc "Run Watir Funtional Specs After completely recreating the db and run all migrations"
  Spec::Rake::SpecTask.new(:watir => "db:remigrate") do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.spec_opts = [
      '--color', '--diff',
      '--format', 'Spec::Ui::ScreenshotFormatter:doc/report/index.html',
      '--format', 'specdoc'
    ]
  end  
  
  desc "Run Watir Funtional Specs Only (Leave DB as it is)"
  Spec::Rake::SpecTask.new(:watir_only) do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.spec_opts = [
      '--color', '--diff',
      '--format', 'Spec::Ui::ScreenshotFormatter:doc/report/index.html',
      '--format', 'specdoc'
    ]
  end  
 
  desc "Run Watir Funtional Specs After completely recreating the db and run all migrations for Continuous Integration"
  Spec::Rake::SpecTask.new(:watir_cc) do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.spec_opts = [
      '--diff',
      '--format', 'Spec::Ui::ScreenshotFormatter:doc/results.html',
      '--format', 'progress'
    ]
  end  

end

desc "Run all specs in spec directory (excluding plugin specs) for Continuous Integration"
Spec::Rake::SpecTask.new(:spec_cc => spec_prereq) do |t|
  ActiveRecord::Migration.verbose = false
  t.spec_opts = [
    '--format', 'html:doc/results.html',
    '--format', 'progress'
  ]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

