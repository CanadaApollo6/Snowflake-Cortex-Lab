/*******************************************************************************
 * CREATE TEST ACCOUNT FOR PRE-EVENT VERIFICATION
 * 
 * Purpose: Create a dedicated test account for validating lab setup
 *          without affecting the 35 attendee accounts (CORTEXLAB01-35)
 * 
 * Run this as: ACCOUNTADMIN
 * When: Before the event, for testing
 * 
 *******************************************************************************/

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- CREATE TEST ACCOUNT
-- ============================================================================

-- Create test role (inherits from shared CORTEX_LAB_USER role)
CREATE ROLE IF NOT EXISTS CORTEXLABTEST_ROLE
  COMMENT = 'Test role for pre-event verification - not for attendees';

-- Grant the shared lab role to test role (role inheritance)
GRANT ROLE CORTEX_LAB_USER TO ROLE CORTEXLABTEST_ROLE;

-- Create test user
CREATE USER IF NOT EXISTS CORTEXLABTEST
  PASSWORD = 'CortexEvent2025!'  -- Same password as real accounts
  DEFAULT_ROLE = 'CORTEXLABTEST_ROLE'
  DEFAULT_WAREHOUSE = 'CORTEX_LAB_WH'
  DEFAULT_NAMESPACE = 'LAB_DATA.CORTEXLABTEST_WORKSPACE'
  MUST_CHANGE_PASSWORD = FALSE
  COMMENT = 'Test account for pre-event verification - DELETE after event';

-- Grant role to user
GRANT ROLE CORTEXLABTEST_ROLE TO USER CORTEXLABTEST;

-- Create test workspace schema
CREATE SCHEMA IF NOT EXISTS LAB_DATA.CORTEXLABTEST_WORKSPACE
  COMMENT = 'Test workspace for pre-event verification';

-- Grant ownership of workspace to test role
GRANT OWNERSHIP ON SCHEMA LAB_DATA.CORTEXLABTEST_WORKSPACE TO ROLE CORTEXLABTEST_ROLE;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify test account was created
SHOW USERS LIKE 'CORTEXLABTEST';

SELECT 
  'Test Account Created' AS status,
  'Username: CORTEXLABTEST' AS detail
UNION ALL SELECT '', 'Password: CortexEvent2025!'
UNION ALL SELECT '', 'Role: CORTEXLABTEST_ROLE'
UNION ALL SELECT '', 'Workspace: LAB_DATA.CORTEXLABTEST_WORKSPACE'
UNION ALL SELECT '', ''
UNION ALL SELECT '✓ Ready for Testing', 'Log out and log in as CORTEXLABTEST';

/*******************************************************************************
 * TESTING INSTRUCTIONS
 * 
 * 1. LOG OUT of Snowflake completely
 * 
 * 2. LOG IN with test credentials:
 *    Username: CORTEXLABTEST
 *    Password: CortexEvent2025!
 * 
 * 3. RUN ALL TESTS below as CORTEXLABTEST user
 * 
 *******************************************************************************/
