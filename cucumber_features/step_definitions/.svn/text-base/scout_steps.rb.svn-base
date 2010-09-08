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

Then /^I should see inbox messages/  do ||
   Given %!I should see "List people to attend the meeting" !
end