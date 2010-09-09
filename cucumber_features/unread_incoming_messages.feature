@scout
Feature : View incoming messages in Inbox
In order to access communications received from other users
system user
wants to view newly received messages and read messages

Scenario: Unread incoming messages should be highlighted in bold
Given I logged into system as "neilmehta"
When I go to incoming_messages
Then I should see a unread message subject line in bold letters
