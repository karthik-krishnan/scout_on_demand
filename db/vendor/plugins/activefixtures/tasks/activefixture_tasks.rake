# desc "Explaining what the task does"
# task :activefixture do
#   # Task goes here
# end
desc "Loading Fixture based on foreign key constraints"
namespace :db do
  namespace :fixtures do    
    desc "Loading Fixture based on foreign key constraints"
    task :activeload => :environment do
      require "activefixture"
      ActiveFixture.load_fixtures
    end
  end
end