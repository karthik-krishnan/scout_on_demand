@scout
Feature : View incoming messages in Inbox
In order to access communications received from other users
system user
wants to view newly received messages and read messagesScenario: View the message details

Scenario: List inbox messages
Given I logged into system as "neilmehta"
When I view unread message
Then I should see "List of people to attend the meeting"
