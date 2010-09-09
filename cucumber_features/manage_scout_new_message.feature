Feature: Manage Scout New Message
    In order to compose a new message
    system user
    wants to create, modify and send the message

    Scenario: Compose a valid message
        Given I logged into system as "Coach"
        And I press "New Message"
        And I fill in "hr@…" for "To"
        And I fill in "ref-121" for "Subject"
        And I enter the message details
        When I press "Send"
        Then I should see the text "Message Sent"

    Scenario: Composing invalid message should result in error
        Given I logged into system as "Coach"
        And I press "New Message"
        And I fill in "ref-121" for "Subject"
        And I enter the message details
        When I press "Validation"
        Then I should see the text "Please enter a recipient" 
