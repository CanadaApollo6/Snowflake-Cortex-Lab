/*******************************************************************************
 * CLEANUP TEST ACCOUNT (OPTIONAL)
 * 
 * Run this as: ACCOUNTADMIN
 * When: After successful testing, before the event
 * 
 * Note: You can also keep the test account for troubleshooting during the event
 * 
 *******************************************************************************/

USE ROLE ACCOUNTADMIN;

-- Option 1: Just clean the workspace (keep account for event-day troubleshooting)
DROP SCHEMA IF EXISTS LAB_DATA.CORTEXLABTEST_WORKSPACE CASCADE;

CREATE SCHEMA LAB_DATA.CORTEXLABTEST_WORKSPACE
  COMMENT = 'Test workspace (cleaned)';

GRANT OWNERSHIP ON SCHEMA LAB_DATA.CORTEXLABTEST_WORKSPACE TO ROLE CORTEXLABTEST_ROLE;

SELECT '✓ Test workspace cleaned - account still available' AS workspace_status;

-- Option 2: Completely remove test account (if you want full cleanup)
-- Uncomment these lines to delete everything:

-- DROP USER IF EXISTS CORTEXLABTEST;
-- DROP ROLE IF EXISTS CORTEXLABTEST_ROLE;
-- DROP SCHEMA IF EXISTS LAB_DATA.CORTEXLABTEST_WORKSPACE CASCADE;

-- SELECT '✓ Test account completely removed' AS status;
