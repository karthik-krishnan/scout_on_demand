#scout

Given /^I logged into system as "(.*)"/ do |user|
#  logoff
#  $browser.goto @host + "ops"
#	$browser.text_field(:name, 'username').value = user
#	$browser.text_field(:name, 'password').value = 'test'
#	$browser.button(:name, 'submit').click
#  assert_successful_response
Given %!I go to incoming_messages!
end

Then /^I should see a list of incoming messages/  do ||
   Given %!I should see "List of people to attend the meeting" !
end

Then /^I should see the most recent message first in inbox list/ do||
  expected_text = 'List of people to attend the meeting'
  elements = $browser.elements_by_xpath("//div[@class='message-content']//a[contains(@class, 'subject')]")
  assert_equal(expected_text, elements[0].text)
end

Then /I should see a unread message subject line in bold letters/ do ||
  expected_text = 'List of people to attend the meeting'
  elements = $browser.elements_by_xpath("//div[@class='message-content']//a[contains(@class, 'unread')]")
  assert_equal(1, elements.size)
  assert_equal(expected_text, elements[0].text)
end

Then /John should have message with subject "(.*)"/ do |subject|
  Given %!I go to incoming_messages?user\=john!
  expected_text = "#{subject}"
  elements = $browser.elements_by_xpath("//div[@class='message-content']//a[contains(@class, 'subject')]")
  assert_equal(expected_text, elements[0].text)
end

Given /I view unread message/ do ||
  Given %!I follow "List of people to attend the meeting" !
#  expected_text = 'List of people to attend the meeting'
#  elements = $browser.elements_by_xpath("//div[@class='message-content']//a[contains(@class, 'subject')]")
#  assert_equal(expected_text, elements[0].text)
end

Then /I should see message detail with subject "(.*)"/ do |subject|
    Then %!I should see "#{subject}!
end
