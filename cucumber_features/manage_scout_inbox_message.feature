
Feature : Manage Inbox 
    In order to access and manage communications from other users
    system user
    wants to view newly received messages, unread messages and remove them.

Scenario: List inbox messages
    Given I logged into system as "neilmehta"
    When I go to incoming_messages
    Then I should see a list of messages

Scenario: View the message details
    Given I logged into system as "Coach"
    When I select a message to "View"
    Then I should see the message datails

Scenario: Mark a message as Unread
    Given I logged into system as "HR"
    When I mark a message as "Unread"
    Then I should see the subject line in bold letters

Scenario: Delete a message from Inbox
    Given I logged into system as "Coach"
    When I mark a message as "Delete"
    Then I should see the message "Message(s) Deleted"
    And I should not see the message in "Inbox"
    And I should see the message in "Trash"
