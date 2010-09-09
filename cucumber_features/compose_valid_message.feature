@scout
Feature: Manage New Message
In order to compose a new message
system user
wants to create, modify and send the message

Scenario: Compose a valid message
Given I logged into system as "Coach"
And I follow "New Message"
And I fill in "john@scout.com" for id "message_mail_to"
And I fill in "ref-121" for id "message_subject"
And I fill in "abc" for id "message_contents"
When I follow "Send"
Then John should have message with subject "ref-121"
