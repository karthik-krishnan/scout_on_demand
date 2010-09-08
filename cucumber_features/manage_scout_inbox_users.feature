Feature: Manage Users
  In order to give controlled access to individuals 
  ScountOnDemand Administrators
  wants to manage users
 
Scenario: Register a user
    Given I go to users/new
    And I fill in "Guru" for "User Id:"
    And I fill in "Krupa" for "User Name:"
    When I press "Create"
    Then I should see text "successfully created"
    

