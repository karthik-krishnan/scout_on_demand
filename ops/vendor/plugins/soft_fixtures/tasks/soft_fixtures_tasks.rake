# desc "Explaining what the task does"
namespace :db do
  namespace :soft_fixtures do
    desc 'Build Soft Fixtures' 
    task :build => :environment do
      require 'active_record/fixtures'
      if File.exists? scenarios_rb = File.join(RAILS_ROOT, 'scenarios', 'scenarios.rb')
        require scenarios_rb
        build_scenario(ENV['SCENARIO'])
      end
    end
  end
end
