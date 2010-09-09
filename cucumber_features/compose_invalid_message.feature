@scout
Feature: Manage New Message
In order to compose a new message
system user
wants to create, modify and send the message

Scenario: Composing invalid message should result in error
Given I logged into system as "Coach"
And I follow "New Message"
And I fill in "ref-121" for id "message_subject"
And I fill in "abc" for id "message_contents"
When I follow "Send"
Then I should see "Please enter a recipient"

