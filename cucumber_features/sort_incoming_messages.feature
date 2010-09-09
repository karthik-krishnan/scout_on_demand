@scout
Feature : View incoming messages in Inbox
In order to access communications received from other users
system user
wants to view newly received messages and read messages

Scenario: Incoming messages should be sorted with most recent ones shown first
Given I logged into system as "neilmehta"
When I go to incoming_messages
Then I should see the most recent message first in inbox list


