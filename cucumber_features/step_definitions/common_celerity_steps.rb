BROWSER = :watir
#BROWSER = :culerity

def watir?
  BROWSER == :watir
end

if watir?
  require 'firewatir'
else
  require 'culerity'
  require 'celerity'
end

require 'benchmark'

Before do
    puts Benchmark.measure {
      Fixtures.reset_cache
      #fixtures_folder = File.join(RAILS_ROOT, 'spec', 'fixtures')
      #fixtures_folder = "/home/msuser1/workspace/forum/integration_testing/scenarios/acceptance_testing"
      #fixtures_folder = "/home/msuser1/workspace/ebanking/integration_testing/scenarios/acceptance_testing"
      fixtures_folder = "/home/msuser1/workspace/scout_inbox/scenarios/test"
      fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
      Fixtures.create_fixtures(fixtures_folder, fixtures)
    }

  #$rails_server ||= Culerity::run_rails
  #sleep 5
  #$server ||= Culerity::run_server
  #$browser = Culerity::RemoteBrowserProxy.new $server, {:browser => :firefox}
  $browser.close rescue nil
  if watir?
    $browser = Watir::Browser.new
  else
    $browser = Celerity::Browser.new(:javascript_exceptions => true, :log_level => :all) 
  end
  #@host = 'http://192.168.2.23:3080/'
  @host = 'http://localhost:3000/'
end

 # The following code will serialize the scheme drt/xls for performance
 # This needs to be done due to reloading of fixtures in the above steps.

Before('@drt_dependent') do
  Given %!I logged in mc as "ADMIN1"!
  Given %!I go to mc/scheme_definitions/serialize_schemes!
  Given %!I go to mc/!
  Given 'I follow "Log Off"'
end

After do
  #Given 'I follow "Log Off"'
  $browser.close
end 

at_exit do
  #$browser.exit if $browser
  $server.exit_server if $server
  Process.kill(6, $rails_server.pid.to_i) if $rails_server
end

When /I press "(.*)"/ do |button|
  $browser.button(:value, button).click
  assert_successful_response
end

When /I follow "(.*)"/ do |link|
  $browser.link(:text, /#{link}/).click
  assert_successful_response
end

When /I fill in "(.*)" for "(.*)"/ do |value, field|
  $browser.text_field(:id, find_label(field).for).value = value
end

When /I set value "(.*)" for "(.*)"/ do |value, field|
  $browser.text_field(:id, find_label(field).for).set(value)
end

When /I check "(.*)"/ do |field|
  $browser.checkbox(:id, find_label(field).for).set(true)
end

When /^I uncheck "(.*)"$/ do |field|
  $browser.checkbox(:id, find_label(field).for).set(false)
end

When /I select "(.*)" from "(.*)"/ do |value, field|
  # Venkat 9Dec09
  # The following code is a coverup for a Rails helper bug when generating list boxes
  # List box's ID generated is different from the label for the list box
  # This could be possible due some of our hacks as well.
  # Need to investigate further
  id_from_label = find_label(field).for
  element = $browser.select_list(:id, id_from_label)
  begin
    element.select value
  rescue
    element = $browser.select_list(:id, id_from_label.chomp('_'))
    element.select value
  end
end

When /I select "(.*)" from id like "(.*)"/ do |value, id|
  $browser.select_list(:id, /#{id}/).value = value
end

When /I select lookup "([^"]+)" with search hint as "(.*)" for "(.*)"/ do |lookup_item, search_hint, field_label|
  $browser.text_field(:id, find_label(field_label).for).set search_hint
  watir_wait_for_ajax_object :link, :text, /#{lookup_item}/
  $browser.link(:text, /#{lookup_item}/).click
end

When /I select lookup "([^"]+)" for "(.*)"/ do |lookup_item, field_label|
  $browser.text_field(:id, find_label(field_label).for).set ""
  xpath_expression = "//div[@class='record-select']//a[contains(text(), '#{lookup_item}')]"
  watir_wait_for_ajax_object :link, :xpath, xpath_expression
  $browser.link(:xpath, xpath_expression).click
end

When /I see a information message "(.*)"/ do |message_text|
  xpath_expression = "//p[contains(@class, 'info-message')][contains(text(), '#{message_text}')]"
  watir_wait_for_ajax_object :element_by_xpath, xpath_expression
end

When /I see a SKU cell with value "(.*)"/ do |sku|
  xpath_expression = "//td[contains(@class, 'sku-column')][contains(text(), '#{sku}')]"
  watir_wait_for_ajax_object :element_by_xpath, xpath_expression
end

When /I see a Status cell with value "(.*)"/ do |status|
  xpath_expression = "//td[contains(@class, 'status')][contains(text(), '#{status}')]"
  watir_wait_for_ajax_object :element_by_xpath, xpath_expression
end

When /I see a open new detail view/ do
  #xpath_expression = "//div[contains(@class, 'new-view')]"
  #watir_wait_for_ajax_object :element_by_xpath, xpath_expression
  Given "/I see a open detail view"
end

When /I see a open edit detail view/ do
  #xpath_expression = "//div[contains(@class, 'edit-view')]"
  #watir_wait_for_ajax_object :element_by_xpath, xpath_expression
  Given "/I see a open detail view"
end

When /I see a open detail view/ do
  xpath_expression = "//div[contains(@class, 'edit-view') or contains(@class, 'new-view')]"
  watir_wait_for_ajax_object :element_by_xpath, xpath_expression
end

When /I see a new detail view closed/ do
  #xpath_expression = "//div[contains(@class, 'new-view')]"
  #watir_wait_for_ajax_object_to_disappear :element_by_xpath, xpath_expression
  Given "I see a detail view closed"
end

When /I see a edit detail view closed/ do
  #xpath_expression = "//div[contains(@class, 'edit-view')]"
  #watir_wait_for_ajax_object_to_disappear :element_by_xpath, xpath_expression
  Given "I see a detail view closed"
end

When /I see a detail view closed/ do
  xpath_expression = "//div[contains(@class, 'edit-view') or contains(@class, 'new-view')]"
  watir_wait_for_ajax_object_to_disappear :element_by_xpath, xpath_expression
end

When /I see a cell with value "(.*)"/ do |expected_value|
  xpath_expression = "//td[contains(text(), '#{expected_value}')]"
  watir_wait_for_ajax_object :element_by_xpath, xpath_expression
end

Given /^I sleep for "(.*)"/ do |seconds|
  sleep seconds.to_i
end

Then /I should see text "(.*)"/ do |text|
 	$browser.text.should include_text(text)
end

When /^I choose radio button with id "(.*)"/ do |id|
  $browser.radio(:id, id).set
end

When /^I check a box with id "(.*)"/ do |id|
  $browser.checkbox(:id, id).set
end

When /^I check a box with id like"(.*)"/ do |id|
  $browser.checkbox(:id, /#{id}/).set
end


When /I fill in "(.*)" for id "(.*)"/ do |value, id|
  $browser.text_field(:id, id).value = value
end

When /I set value "(.*)" for id "(.*)"/ do |value, id|
  $browser.text_field(:id, id).set(value)
end

When /I fill in "(.*)" for id like "(.*)"/ do |value, id|
  $browser.text_field(:id, /#{id}/).value = value
end

When /I follow id like "(.*)"/ do |id|
  $browser.link(:id, /#{id}/).click
  assert_successful_response
end

When /I choose "(.*)"/ do |field|
  $browser.radio(:id, find_label(field).for).set(true)
end

When /I go to (.+)/ do |path|
  #$browser.goto @host + path_to(path)
  $browser.goto @host + path
  assert_successful_response
end

When /I wait for the AJAX call to finish/ do
  $browser.wait
end

Then /I should see "(.*)"/ do |text|
  # if we simply check for the browser.html content we don't find content that has been added dynamically, e.g. after an ajax call
  div = $browser.div(:text, /#{text}/)
  begin
    div.html
  rescue
    #puts $browser.html
    raise("div with '#{text}' not found")
  end
end

Then /I should not see "(.*)"/ do |text|
  div = $browser.div(:text, /#{text}/).html rescue nil
  div.should be_nil
end

def find_label(text)
  $browser.label :text, text
end

def assert_successful_response
  return true if watir?
  status = $browser.page.web_response.status_code
  if(status == 302 || status == 301)
    location = $browser.page.web_response.get_response_header_value('Location')
    puts "Being redirected to #{location}"
    $browser.goto location
    assert_successful_response
  elsif status != 200
    tmp = Tempfile.new 'culerity_results'
    tmp << $browser.html
    tmp.close
    `open -a /Applications/Safari.app #{tmp.path}`
    raise "Brower returned Response Code #{$browser.page.web_response.status_code}"
  end
end
