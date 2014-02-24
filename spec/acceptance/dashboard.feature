Feature: Dashboard
  Background:
    Given a confirmed user with a profile

  Scenario: Successful login
    When I go to the 'sign_in' page
    When I log in with user 'joe@citizen.org' and password 'Password1'
    Then I should be on the dashboard page
    And I should see the message 'You have signed in successfully'

  Scenario: Unuccessful login
    When I go to the 'sign_in' page
    When I log in with user 'joe@citizen.org' and password 'WrongPassword'
    Then I should be on the sign_in page
    And I should see the message "We don't recognize that email or password"
