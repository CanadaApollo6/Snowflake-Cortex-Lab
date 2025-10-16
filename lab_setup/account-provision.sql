/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - ACCOUNT PROVISIONING
 * 
 * Purpose: Create 30 lab accounts with isolated workspaces and shared data access
 * Run Date: [DATE]
 * Event: [EVENT NAME]
 * 
 * Prerequisites:
 * - Run as ACCOUNTADMIN role
 * - Ensure CORTEX privileges are available in your account
 * - Verify LAB_DATA database exists (or will be created)
 * 
 * Execution Time: ~2-3 minutes
 *******************************************************************************/

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- SECTION 1: CREATE CORE INFRASTRUCTURE
-- ============================================================================

-- Create dedicated warehouse for lab (adjust size based on expected load)
CREATE WAREHOUSE IF NOT EXISTS CORTEX_LAB_WH
  WITH WAREHOUSE_SIZE = 'MEDIUM'
       AUTO_SUSPEND = 60
       AUTO_RESUME = TRUE
       INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for Cortex AI Lab - November 2024';

-- Create lab database for shared datasets
CREATE DATABASE IF NOT EXISTS LAB_DATA
  COMMENT = 'Shared datasets for Cortex AI Lab';

USE DATABASE LAB_DATA;

-- Create schema for shared sample data
CREATE SCHEMA IF NOT EXISTS SAMPLES
  COMMENT = 'Read-only sample datasets for all lab users';

-- Create schema for shared Cortex Search services (if using)
CREATE SCHEMA IF NOT EXISTS CORTEX_SERVICES
  COMMENT = 'Shared Cortex Search services';

-- ============================================================================
-- SECTION 2: CREATE LAB USER ROLE
-- ============================================================================

CREATE ROLE IF NOT EXISTS CORTEX_LAB_USER
  COMMENT = 'Role for Cortex AI Lab participants';

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE CORTEX_LAB_WH TO ROLE CORTEX_LAB_USER;

-- Grant database and schema access (read-only on shared data)
GRANT USAGE ON DATABASE LAB_DATA TO ROLE CORTEX_LAB_USER;
GRANT USAGE ON SCHEMA LAB_DATA.SAMPLES TO ROLE CORTEX_LAB_USER;
GRANT USAGE ON SCHEMA LAB_DATA.CORTEX_SERVICES TO ROLE CORTEX_LAB_USER;
GRANT SELECT ON ALL TABLES IN SCHEMA LAB_DATA.SAMPLES TO ROLE CORTEX_LAB_USER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA LAB_DATA.SAMPLES TO ROLE CORTEX_LAB_USER;

-- Grant Cortex AI privileges (adjust based on your Snowflake version)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE CORTEX_LAB_USER;

-- Alternative if the above doesn't work (older Snowflake versions):
-- GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.COMPLETE TO ROLE CORTEX_LAB_USER;
-- GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.SENTIMENT TO ROLE CORTEX_LAB_USER;
-- GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.SUMMARIZE TO ROLE CORTEX_LAB_USER;
-- GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.TRANSLATE TO ROLE CORTEX_LAB_USER;

-- ============================================================================
-- SECTION 3: CREATE USER ACCOUNTS AND WORKSPACES
-- ============================================================================

-- Variable declarations for user creation
SET NUM_USERS = 30;
SET PASSWORD = 'CortexEvent2024!'; -- CHANGE THIS to your preferred password
SET COUNTER = 1;

-- Create users in a loop
BEGIN
  FOR i IN 1 TO 30 DO
    LET username VARCHAR := 'CORTEXLAB' || LPAD(i::STRING, 2, '0');
    LET schema_name VARCHAR := 'CORTEXLAB' || LPAD(i::STRING, 2, '0') || '_WORKSPACE';
    
    -- Create user
    EXECUTE IMMEDIATE 
      'CREATE USER IF NOT EXISTS IDENTIFIER(:1) 
       PASSWORD = :2
       DEFAULT_ROLE = ''CORTEX_LAB_USER''
       DEFAULT_WAREHOUSE = ''CORTEX_LAB_WH''
       DEFAULT_NAMESPACE = ''LAB_DATA.' || :schema_name || '''
       MUST_CHANGE_PASSWORD = FALSE
       COMMENT = ''Lab participant - created ' || CURRENT_TIMESTAMP()::STRING || ''''
      USING (username, $PASSWORD);
    
    -- Grant role to user
    EXECUTE IMMEDIATE 
      'GRANT ROLE CORTEX_LAB_USER TO USER IDENTIFIER(:1)'
      USING (username);
    
    -- Create personal workspace schema
    EXECUTE IMMEDIATE
      'CREATE SCHEMA IF NOT EXISTS LAB_DATA.IDENTIFIER(:1)
       COMMENT = ''Personal workspace for ' || :username || ''''
      USING (schema_name);
    
    -- Grant full privileges on personal workspace
    EXECUTE IMMEDIATE
      'GRANT ALL PRIVILEGES ON SCHEMA LAB_DATA.IDENTIFIER(:1) TO USER IDENTIFIER(:2)'
      USING (schema_name, username);
    
    -- Grant create table/view privileges
    EXECUTE IMMEDIATE
      'GRANT CREATE TABLE ON SCHEMA LAB_DATA.IDENTIFIER(:1) TO USER IDENTIFIER(:2)'
      USING (schema_name, username);
      
    EXECUTE IMMEDIATE
      'GRANT CREATE VIEW ON SCHEMA LAB_DATA.IDENTIFIER(:1) TO USER IDENTIFIER(:2)'
      USING (schema_name, username);
  END FOR;
  
  RETURN 'Successfully created ' || :NUM_USERS || ' lab accounts';
END;

-- ============================================================================
-- SECTION 4: VERIFICATION
-- ============================================================================

-- Verify all users were created
SELECT 
  'User Accounts' AS object_type,
  COUNT(*) AS count,
  CASE 
    WHEN COUNT(*) = 30 THEN '✓ PASS'
    ELSE '✗ FAIL - Expected 30 users'
  END AS status
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE NAME LIKE 'CORTEXLAB%'
  AND DELETED IS NULL;

-- Verify all schemas were created
SELECT 
  'Workspace Schemas' AS object_type,
  COUNT(*) AS count,
  CASE 
    WHEN COUNT(*) >= 30 THEN '✓ PASS'
    ELSE '✗ FAIL - Expected 30+ schemas'
  END AS status
FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE SCHEMA_NAME LIKE 'CORTEXLAB%_WORKSPACE'
  AND DELETED IS NULL;

-- List all created users with their default settings
SELECT 
  NAME AS username,
  DEFAULT_WAREHOUSE,
  DEFAULT_NAMESPACE,
  DEFAULT_ROLE,
  CREATED_ON
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE NAME LIKE 'CORTEXLAB%'
  AND DELETED IS NULL
ORDER BY NAME;

-- ============================================================================
-- SECTION 5: GENERATE LOGIN CREDENTIALS (for printing)
-- ============================================================================

SELECT 
  ROW_NUMBER() OVER (ORDER BY NAME) AS attendee_number,
  NAME AS username,
  'CortexEvent2024!' AS password,  -- Replace with your actual password
  'CORTEX_LAB_WH' AS warehouse,
  'LAB_DATA' AS database,
  REPLACE(NAME, 'CORTEXLAB', 'CORTEXLAB') || '_WORKSPACE' AS personal_schema
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE NAME LIKE 'CORTEXLAB%'
  AND DELETED IS NULL
ORDER BY NAME;

/*******************************************************************************
 * POST-SETUP CHECKLIST:
 * 
 * □ All 30 users created successfully
 * □ All 30 workspace schemas created
 * □ Test login with cortexlab01 account
 * □ Verify Cortex functions work: SELECT SNOWFLAKE.CORTEX.COMPLETE(...)
 * □ Load sample datasets into LAB_DATA.SAMPLES schema
 * □ Print credential cards for attendees
 * □ Set calendar reminder to run cleanup script after event
 * 
 *******************************************************************************/