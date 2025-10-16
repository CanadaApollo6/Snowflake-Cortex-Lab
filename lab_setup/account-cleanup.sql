/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - ACCOUNT CLEANUP
 * 
 * Purpose: Remove all lab accounts and workspaces after event
 * Run Date: [DATE - typically 7-14 days after event]
 * 
 * WARNING: This script will permanently delete:
 * - All 30 lab user accounts
 * - All personal workspace schemas and their data
 * - The lab warehouse
 * - Optionally: the entire LAB_DATA database
 * 
 * Prerequisites:
 * - Run as ACCOUNTADMIN role
 * - Verify event is complete and no ongoing access needed
 * - Consider backing up any interesting queries/work first
 * 
 * Execution Time: ~1-2 minutes
 *******************************************************************************/

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- SECTION 1: PRE-CLEANUP VERIFICATION
-- ============================================================================

-- Review what will be deleted
SELECT 
  'Lab Users to Delete' AS category,
  COUNT(*) AS count
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE NAME LIKE 'CORTEXLAB%'
  AND DELETED IS NULL;

SELECT 
  'Workspace Schemas to Delete' AS category,
  COUNT(*) AS count
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE SCHEMA_NAME LIKE 'CORTEXLAB%_WORKSPACE'
  AND DELETED IS NULL;

-- Check for any recent activity (last 7 days)
SELECT 
  USER_NAME,
  COUNT(*) AS query_count,
  MAX(END_TIME) AS last_activity
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE USER_NAME LIKE 'CORTEXLAB%'
  AND END_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY USER_NAME
ORDER BY last_activity DESC;

/*
  MANUAL CHECKPOINT: Review the above results
  
  If you see recent activity, consider:
  - Extending the cleanup date
  - Contacting active users about the upcoming deletion
  - Backing up any work they want to keep
  
  Type 'CONTINUE' below when ready to proceed with deletion
*/

-- ============================================================================
-- SECTION 2: BACKUP OPTION (OPTIONAL)
-- ============================================================================

-- Optional: Create backup of interesting queries before cleanup
CREATE OR REPLACE TABLE ADMIN_BACKUPS.LAB_QUERY_HISTORY AS
SELECT 
  QUERY_ID,
  QUERY_TEXT,
  USER_NAME,
  WAREHOUSE_NAME,
  START_TIME,
  END_TIME,
  TOTAL_ELAPSED_TIME,
  ROWS_PRODUCED,
  EXECUTION_STATUS
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE USER_NAME LIKE 'CORTEXLAB%'
  AND START_TIME >= '[EVENT_START_DATE]'  -- Replace with actual date
ORDER BY START_TIME;

-- Optional: Export this to CSV before deletion
-- SELECT * FROM ADMIN_BACKUPS.LAB_QUERY_HISTORY;

-- ============================================================================
-- SECTION 3: DELETE USER ACCOUNTS
-- ============================================================================

-- Drop all lab user accounts
BEGIN
  FOR user_record IN (
    SELECT NAME 
    FROM SNOWFLAKE.ACCOUNT_USAGE.USERS 
    WHERE NAME LIKE 'CORTEXLAB%' 
      AND DELETED IS NULL
  ) DO
    EXECUTE IMMEDIATE 'DROP USER IF EXISTS IDENTIFIER(:1)' USING (user_record.NAME);
  END FOR;
  
  RETURN 'All lab user accounts deleted';
END;

-- ============================================================================
-- SECTION 4: DELETE WORKSPACE SCHEMAS
-- ============================================================================

-- Drop all personal workspace schemas
USE DATABASE LAB_DATA;

BEGIN
  FOR schema_record IN (
    SELECT SCHEMA_NAME 
    FROM INFORMATION_SCHEMA.SCHEMATA 
    WHERE SCHEMA_NAME LIKE 'CORTEXLAB%_WORKSPACE'
  ) DO
    EXECUTE IMMEDIATE 'DROP SCHEMA IF EXISTS LAB_DATA.IDENTIFIER(:1) CASCADE' 
      USING (schema_record.SCHEMA_NAME);
  END FOR;
  
  RETURN 'All workspace schemas deleted';
END;

-- ============================================================================
-- SECTION 5: DELETE LAB ROLE
-- ============================================================================

DROP ROLE IF EXISTS CORTEX_LAB_USER;

-- ============================================================================
-- SECTION 6: DELETE LAB WAREHOUSE
-- ============================================================================

DROP WAREHOUSE IF EXISTS CORTEX_LAB_WH;

-- ============================================================================
-- SECTION 7: CLEANUP LAB DATABASE (OPTIONAL)
-- ============================================================================

/*
  DECISION POINT: Do you want to delete the entire LAB_DATA database?
  
  Keep it if:
  - You'll run this lab again soon
  - Sample datasets are expensive to reload
  - You want to reference the lab setup later
  
  Delete it if:
  - This was a one-time event
  - You want a complete cleanup
  - Storage costs are a concern
  
  Uncomment the line below to delete the entire database:
*/

-- DROP DATABASE IF EXISTS LAB_DATA CASCADE;

-- Or, keep the database but just drop the sample data:
DROP SCHEMA IF EXISTS LAB_DATA.SAMPLES CASCADE;
DROP SCHEMA IF EXISTS LAB_DATA.CORTEX_SERVICES CASCADE;

-- ============================================================================
-- SECTION 8: POST-CLEANUP VERIFICATION
-- ============================================================================

-- Verify all users are deleted
SELECT 
  'Remaining Lab Users' AS check_type,
  COUNT(*) AS count,
  CASE 
    WHEN COUNT(*) = 0 THEN '✓ PASS - All deleted'
    ELSE '✗ FAIL - Users still exist'
  END AS status
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE NAME LIKE 'CORTEXLAB%'
  AND DELETED IS NULL;

-- Verify all schemas are deleted
SELECT 
  'Remaining Workspace Schemas' AS check_type,
  COUNT(*) AS count,
  CASE 
    WHEN COUNT(*) = 0 THEN '✓ PASS - All deleted'
    ELSE '✗ FAIL - Schemas still exist'
  END AS status
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE SCHEMA_NAME LIKE 'CORTEXLAB%_WORKSPACE'
  AND DELETED IS NULL;

-- Verify warehouse is deleted
SELECT 
  'CORTEX_LAB_WH Warehouse' AS check_type,
  COUNT(*) AS count,
  CASE 
    WHEN COUNT(*) = 0 THEN '✓ PASS - Deleted'
    ELSE '✗ FAIL - Still exists'
  END AS status
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES
WHERE WAREHOUSE_NAME = 'CORTEX_LAB_WH'
  AND DELETED IS NULL;

-- Verify role is deleted
SELECT 
  'CORTEX_LAB_USER Role' AS check_type,
  COUNT(*) AS count,
  CASE 
    WHEN COUNT(*) = 0 THEN '✓ PASS - Deleted'
    ELSE '✗ FAIL - Still exists'
  END AS status
FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
WHERE NAME = 'CORTEX_LAB_USER'
  AND DELETED IS NULL;

-- Final summary
SELECT 
  '=== CLEANUP COMPLETE ===' AS status,
  CURRENT_TIMESTAMP() AS completed_at;

/*******************************************************************************
 * POST-CLEANUP CHECKLIST:
 * 
 * □ All verification checks passed
 * □ Query history backed up (if desired)
 * □ No unexpected remaining objects
 * □ Document cleanup date in event records
 * □ Update any documentation that referenced these accounts
 * 
 * CLEANUP SUMMARY:
 * - 30 user accounts: DELETED
 * - 30 workspace schemas: DELETED
 * - 1 dedicated warehouse: DELETED
 * - 1 lab role: DELETED
 * - Sample data: [DELETED/RETAINED - update based on your choice]
 * 
 *******************************************************************************/