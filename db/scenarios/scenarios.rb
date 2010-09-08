class SoftFixturesBuilder
    include FixtureReplacement
end

Dir.glob(File.dirname(__FILE__) + "/**/*_scenario.rb").each do |file|
    require file
end
