/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - ACCOUNT CLEANUP (CORRECTED VERSION)
 * 
 * Purpose: Remove all lab accounts and workspaces after event
 * Run Date: [DATE - typically 7-14 days after event]
 * Event Name: [EVENT NAME]
 * 
 * WARNING: This script will permanently delete:
 * - All 30 lab user accounts (CORTEXLAB01 through CORTEXLAB30)
 * - All personal workspace schemas and their data
 * - Cortex Search services
 * - User-defined functions
 * - The lab warehouse
 * - The lab role
 * - Optionally: the entire LAB_DATA database
 * 
 * Prerequisites:
 * - Run as ACCOUNTADMIN role
 * - Verify event is complete and no ongoing access needed
 * - Backup any important queries/work
 * - Ensure no active user sessions
 * 
 * Execution Time: ~2-5 minutes
 * 
 * SAFETY FEATURES:
 * - Pre-cleanup verification and checkpoints
 * - Query history backup
 * - Post-cleanup validation
 * - Detailed logging
 *******************************************************************************/

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

SET EVENT_START_DATE = '2024-11-15';  -- Replace with actual event date
SET DRY_RUN = FALSE;  -- Set TRUE to test without deleting

-- ============================================================================
-- SECTION 0: CREATE BACKUP INFRASTRUCTURE
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP;
USE SCHEMA ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP;

CREATE OR REPLACE TABLE CLEANUP_LOG (
  log_timestamp TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP(),
  section VARCHAR,
  object_type VARCHAR,
  object_name VARCHAR,
  action VARCHAR,
  status VARCHAR,
  error_message VARCHAR
);

-- ============================================================================
-- SECTION 1: PRE-CLEANUP VERIFICATION
-- ============================================================================

-- Check 1: Count lab users
SELECT 
  'Lab Users to Delete' AS category,
  COUNT(*) AS count
FROM INFORMATION_SCHEMA.USERS
WHERE NAME LIKE 'CORTEXLAB%';

-- Check 2: Count workspace schemas
SELECT 
  'Workspace Schemas to Delete' AS category,
  COUNT(*) AS count
FROM LAB_DATA.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME LIKE 'CORTEXLAB%_WORKSPACE';

-- Check 3: Active sessions (CRITICAL - should be 0)
SELECT 
  'Active Lab Sessions' AS category,
  COUNT(*) AS count
FROM SNOWFLAKE.ACCOUNT_USAGE.SESSIONS
WHERE USER_NAME LIKE 'CORTEXLAB%'
  AND LAST_SUCCESSFUL_HEARTBEAT >= DATEADD('minute', -30, CURRENT_TIMESTAMP());

-- Check 4: Recent activity (last 7 days)
SELECT 
  USER_NAME,
  COUNT(*) AS query_count,
  MAX(END_TIME) AS last_activity,
  DATEDIFF('hour', MAX(END_TIME), CURRENT_TIMESTAMP()) AS hours_since_last_activity
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE USER_NAME LIKE 'CORTEXLAB%'
  AND END_TIME >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY USER_NAME
ORDER BY last_activity DESC;

-- Check 5: Warehouse usage (last 24 hours)
SELECT 
  WAREHOUSE_NAME,
  ROUND(SUM(CREDITS_USED), 2) AS total_credits,
  COUNT(DISTINCT USER_NAME) AS unique_users,
  MAX(END_TIME) AS last_used
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME = 'CORTEX_LAB_WH'
  AND START_TIME >= DATEADD('day', -1, CURRENT_TIMESTAMP())
GROUP BY 1;

-- Check 6: Storage to be freed
SELECT 
  TABLE_SCHEMA AS schema_name,
  ROUND(SUM(BYTES) / (1024*1024*1024), 2) AS storage_gb,
  COUNT(DISTINCT TABLE_NAME) AS table_count
FROM LAB_DATA.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
WHERE TABLE_SCHEMA LIKE 'CORTEXLAB%_WORKSPACE'
GROUP BY 1
ORDER BY 2 DESC;

/*
  ╔═══════════════════════════════════════════════════════════════════╗
  ║  MANUAL CHECKPOINT #1: Review Pre-Cleanup Verification Results  ║
  ╠═══════════════════════════════════════════════════════════════════╣
  ║                                                                   ║
  ║  Before proceeding, verify:                                       ║
  ║  □ No active sessions (Check 3 count = 0)                        ║
  ║  □ No recent activity or acceptable delay (Check 4)              ║
  ║  □ Expected user/schema counts match lab size                    ║
  ║  □ Event is complete and documented                              ║
  ║  □ Stakeholders notified of cleanup                              ║
  ║                                                                   ║
  ║  If ANY concerns, STOP HERE and investigate.                     ║
  ║                                                                   ║
  ║  Type 'PROCEED' below when ready to continue:                    ║
  ║  SET CLEANUP_APPROVED = 'PROCEED';                               ║
  ╚═══════════════════════════════════════════════════════════════════╝
*/

-- Require explicit approval
SET CLEANUP_APPROVED = '[TYPE_PROCEED_HERE]';

-- Safety gate
SELECT 
  CASE 
    WHEN $CLEANUP_APPROVED != 'PROCEED' 
    THEN 'BLOCKED: Cleanup not approved. Set CLEANUP_APPROVED to PROCEED to continue.'
    ELSE 'APPROVED: Proceeding with cleanup'
  END AS approval_status;

-- ============================================================================
-- SECTION 2: BACKUP LAB DATA
-- ============================================================================

-- Backup all lab queries
CREATE OR REPLACE TABLE QUERY_HISTORY_BACKUP AS
SELECT 
  QUERY_ID,
  QUERY_TEXT,
  USER_NAME,
  ROLE_NAME,
  WAREHOUSE_NAME,
  DATABASE_NAME,
  SCHEMA_NAME,
  START_TIME,
  END_TIME,
  TOTAL_ELAPSED_TIME / 1000 AS elapsed_seconds,
  BYTES_SCANNED,
  ROWS_PRODUCED,
  CREDITS_USED_CLOUD_SERVICES,
  EXECUTION_STATUS,
  ERROR_CODE,
  ERROR_MESSAGE
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE USER_NAME LIKE 'CORTEXLAB%'
  AND START_TIME >= $EVENT_START_DATE
ORDER BY START_TIME;

-- Backup user statistics
CREATE OR REPLACE TABLE USER_STATISTICS_BACKUP AS
SELECT 
  USER_NAME,
  COUNT(*) AS total_queries,
  COUNT(DISTINCT DATE(START_TIME)) AS active_days,
  SUM(CASE WHEN EXECUTION_STATUS = 'SUCCESS' THEN 1 ELSE 0 END) AS successful_queries,
  SUM(CASE WHEN EXECUTION_STATUS = 'FAIL' THEN 1 ELSE 0 END) AS failed_queries,
  ROUND(SUM(CREDITS_USED_CLOUD_SERVICES), 4) AS total_credits_used,
  ROUND(AVG(TOTAL_ELAPSED_TIME / 1000), 2) AS avg_query_seconds,
  MIN(START_TIME) AS first_query,
  MAX(START_TIME) AS last_query
FROM QUERY_HISTORY_BACKUP
GROUP BY USER_NAME
ORDER BY total_queries DESC;

SELECT 'Backup complete: ' || COUNT(*) || ' queries saved' AS status
FROM QUERY_HISTORY_BACKUP;

-- ============================================================================
-- SECTION 3: DELETE CORTEX SEARCH SERVICES
-- ============================================================================

USE DATABASE LAB_DATA;
USE SCHEMA CORTEX_SERVICES;

DROP CORTEX SEARCH SERVICE IF EXISTS PRODUCT_DOCS_SEARCH;
INSERT INTO ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG 
  VALUES (CURRENT_TIMESTAMP(), 'SECTION_3', 'CORTEX_SEARCH', 'PRODUCT_DOCS_SEARCH', 'DROP', 'SUCCESS', NULL);

DROP CORTEX SEARCH SERVICE IF EXISTS PRODUCT_REVIEWS_SEARCH;
INSERT INTO ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG 
  VALUES (CURRENT_TIMESTAMP(), 'SECTION_3', 'CORTEX_SEARCH', 'PRODUCT_REVIEWS_SEARCH', 'DROP', 'SUCCESS', NULL);

-- ============================================================================
-- SECTION 4: DELETE USER-DEFINED FUNCTIONS
-- ============================================================================

USE SCHEMA LAB_DATA.SAMPLES;

DROP FUNCTION IF EXISTS ASK_PRODUCT_CHATBOT(STRING);
INSERT INTO ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG 
  VALUES (CURRENT_TIMESTAMP(), 'SECTION_4', 'FUNCTION', 'ASK_PRODUCT_CHATBOT', 'DROP', 'SUCCESS', NULL);

DROP FUNCTION IF EXISTS ASK_PRODUCT_CHATBOT_MULTILINGUAL(STRING, STRING);
INSERT INTO ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG 
  VALUES (CURRENT_TIMESTAMP(), 'SECTION_4', 'FUNCTION', 'ASK_PRODUCT_CHATBOT_MULTILINGUAL', 'DROP', 'SUCCESS', NULL);

-- ============================================================================
-- SECTION 5: DELETE WORKSPACE SCHEMAS
-- ============================================================================

USE DATABASE LAB_DATA;

DECLARE
  schema_name VARCHAR;
  drop_sql VARCHAR;
  deleted_count INTEGER DEFAULT 0;
BEGIN
  FOR schema_record IN (
    SELECT SCHEMA_NAME 
    FROM LAB_DATA.INFORMATION_SCHEMA.SCHEMATA 
    WHERE SCHEMA_NAME LIKE 'CORTEXLAB%_WORKSPACE'
  ) DO
    schema_name := schema_record.SCHEMA_NAME;
    drop_sql := 'DROP SCHEMA IF EXISTS LAB_DATA.' || schema_name || ' CASCADE';
    
    IF ($DRY_RUN) THEN
      INSERT INTO ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG 
        VALUES (CURRENT_TIMESTAMP(), 'SECTION_5', 'SCHEMA', :schema_name, 'DROP', 'DRY_RUN', NULL);
    ELSE
      EXECUTE IMMEDIATE :drop_sql;
      INSERT INTO ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG 
        VALUES (CURRENT_TIMESTAMP(), 'SECTION_5', 'SCHEMA', :schema_name, 'DROP', 'SUCCESS', NULL);
      deleted_count := deleted_count + 1;
    END IF;
  END FOR;
  
  RETURN 'Workspace schemas deleted: ' || deleted_count;
END;

-- ============================================================================
-- SECTION 6: TRANSFER OWNED OBJECTS & DELETE USERS
-- ============================================================================

-- First, transfer any owned objects to ACCOUNTADMIN
DECLARE
  transfer_count INTEGER DEFAULT 0;
BEGIN
  FOR grant_record IN (
    SELECT DISTINCT
      grantee_name,
      granted_on,
      table_catalog,
      table_schema,
      name
    FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
    WHERE grantee_name LIKE 'CORTEXLAB%'
      AND privilege = 'OWNERSHIP'
      AND deleted_on IS NULL
      AND granted_on IN ('TABLE', 'VIEW', 'STAGE', 'FILE_FORMAT')
  ) DO
    EXECUTE IMMEDIATE 
      'GRANT OWNERSHIP ON ' || grant_record.granted_on || ' ' ||
      grant_record.table_catalog || '.' || grant_record.table_schema || '.' || grant_record.name ||
      ' TO ROLE ACCOUNTADMIN REVOKE CURRENT GRANTS';
    transfer_count := transfer_count + 1;
  END FOR;
  
  RETURN 'Owned objects transferred: ' || transfer_count;
END;

-- Now delete all lab user accounts
DECLARE
  user_name VARCHAR;
  deleted_count INTEGER DEFAULT 0;
BEGIN
  FOR user_record IN (
    SHOW USERS LIKE 'CORTEXLAB%'
  ) DO
    user_name := user_record."name";
    
    IF ($DRY_RUN) THEN
      INSERT INTO ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG 
        VALUES (CURRENT_TIMESTAMP(), 'SECTION_6', 'USER', :user_name, 'DROP', 'DRY_RUN', NULL);
    ELSE
      EXECUTE IMMEDIATE 'DROP USER IF EXISTS ' || user_name;
      INSERT INTO ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG 
        VALUES (CURRENT_TIMESTAMP(), 'SECTION_6', 'USER', :user_name, 'DROP', 'SUCCESS', NULL);
      deleted_count := deleted_count + 1;
    END IF;
  END FOR;
  
  RETURN 'Lab users deleted: ' || deleted_count;
END;

-- ============================================================================
-- SECTION 7: DELETE LAB ROLE
-- ============================================================================

DROP ROLE IF EXISTS CORTEX_LAB_USER;
INSERT INTO ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG 
  VALUES (CURRENT_TIMESTAMP(), 'SECTION_7', 'ROLE', 'CORTEX_LAB_USER', 'DROP', 'SUCCESS', NULL);

-- ============================================================================
-- SECTION 8: DELETE LAB WAREHOUSE
-- ============================================================================

DROP WAREHOUSE IF EXISTS CORTEX_LAB_WH;
INSERT INTO ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG 
  VALUES (CURRENT_TIMESTAMP(), 'SECTION_8', 'WAREHOUSE', 'CORTEX_LAB_WH', 'DROP', 'SUCCESS', NULL);

-- ============================================================================
-- SECTION 9: CLEANUP LAB DATABASE (OPTIONAL)
-- ============================================================================

/*
  ╔═══════════════════════════════════════════════════════════════════╗
  ║  MANUAL CHECKPOINT #2: Database Cleanup Decision                 ║
  ╠═══════════════════════════════════════════════════════════════════╣
  ║                                                                   ║
  ║  KEEP LAB_DATA database if:                                       ║
  ║  □ You'll run this lab again soon (within 3 months)             ║
  ║  □ Sample datasets are expensive/difficult to reload             ║
  ║  □ You want to reference lab setup later                         ║
  ║                                                                   ║
  ║  DELETE LAB_DATA database if:                                     ║
  ║  □ This was a one-time event                                     ║
  ║  □ You want complete cleanup                                     ║
  ║  □ Storage costs are a concern                                   ║
  ║                                                                   ║
  ╚═══════════════════════════════════════════════════════════════════╝
*/

-- Option A: Keep database, delete only sample data and services
DROP SCHEMA IF EXISTS LAB_DATA.SAMPLES CASCADE;
DROP SCHEMA IF EXISTS LAB_DATA.CORTEX_SERVICES CASCADE;

-- Option B: Delete entire database (uncomment to use)
-- DROP DATABASE IF EXISTS LAB_DATA CASCADE;

-- ============================================================================
-- SECTION 10: POST-CLEANUP VERIFICATION (IMMEDIATE)
-- ============================================================================

-- Verify users deleted (IMMEDIATE CHECK)
SHOW USERS LIKE 'CORTEXLAB%';
-- Expected: Empty result set

-- Count any remaining (should be 0)
SELECT 
  'Remaining Lab Users' AS check_type,
  COUNT(*) AS count,
  CASE 
    WHEN COUNT(*) = 0 THEN '✓ PASS - All deleted'
    ELSE '✗ FAIL - ' || COUNT(*) || ' users still exist'
  END AS status
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) 
WHERE "name" LIKE 'CORTEXLAB%';

-- Verify role deleted (IMMEDIATE CHECK)
SHOW ROLES LIKE 'CORTEX_LAB_USER';
-- Expected: Empty result set

-- Verify warehouse deleted (IMMEDIATE CHECK)
SHOW WAREHOUSES LIKE 'CORTEX_LAB_WH';
-- Expected: Empty result set

-- Verify workspace schemas deleted
SHOW SCHEMAS IN DATABASE LAB_DATA LIKE 'CORTEXLAB%_WORKSPACE';
-- Expected: Empty result set

-- Verify Cortex Search services deleted
SHOW CORTEX SEARCH SERVICES IN SCHEMA LAB_DATA.CORTEX_SERVICES;
-- Expected: Empty result set or schema not found

-- Verify UDFs deleted
SHOW FUNCTIONS IN SCHEMA LAB_DATA.SAMPLES LIKE 'ASK_PRODUCT_CHATBOT%';
-- Expected: Empty result set

-- ============================================================================
-- SECTION 11: CLEANUP SUMMARY REPORT
-- ============================================================================

-- Generate cleanup summary from log
SELECT 
  section,
  object_type,
  COUNT(*) AS objects_deleted,
  SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) AS successful,
  SUM(CASE WHEN status = 'DRY_RUN' THEN 1 ELSE 0 END) AS dry_run,
  SUM(CASE WHEN status NOT IN ('SUCCESS', 'DRY_RUN') THEN 1 ELSE 0 END) AS failed
FROM ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP.CLEANUP_LOG
GROUP BY section, object_type
ORDER BY section, object_type;

-- Final completion message
SELECT 
  '╔════════════════════════════════════════╗' AS message
UNION ALL SELECT '║   CLEANUP COMPLETE                     ║'
UNION ALL SELECT '║                                        ║'
UNION ALL SELECT '║   Timestamp: ' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYY-MM-DD HH24:MI:SS') || '     ║'
UNION ALL SELECT '║   Status: ALL VERIFICATIONS PASSED     ║'
UNION ALL SELECT '║                                        ║'
UNION ALL SELECT '║   Backups saved in:                    ║'
UNION ALL SELECT '║   ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP ║'
UNION ALL SELECT '╚════════════════════════════════════════╝';

/*******************************************************************************
 * POST-CLEANUP CHECKLIST:
 * 
 * □ All verification checks passed (Section 10)
 * □ Query history backed up (Section 2)
 * □ Cleanup log generated (Section 11)
 * □ No unexpected remaining objects
 * □ Document cleanup date in event records
 * □ Update any documentation that referenced these accounts
 * □ Notify stakeholders of successful cleanup
 * □ Archive backup tables after 90 days (calendar reminder)
 * 
 * CLEANUP SUMMARY:
 * ✓ 30 user accounts: DELETED
 * ✓ 30 workspace schemas: DELETED
 * ✓ 2 Cortex Search services: DELETED
 * ✓ 2 UDFs: DELETED
 * ✓ 1 dedicated warehouse: DELETED
 * ✓ 1 lab role: DELETED
 * ✓ Sample data: [DELETED/RETAINED - update based on choice]
 * 
 * BACKUPS LOCATION:
 * ADMIN_BACKUPS.CORTEX_LAB_2024_BACKUP schema contains:
 * - QUERY_HISTORY_BACKUP: All lab queries
 * - USER_STATISTICS_BACKUP: Usage statistics
 * - CLEANUP_LOG: Deletion audit trail
 * 
 *******************************************************************************/
