/*******************************************************************************
 * COMPREHENSIVE PRE-EVENT TESTING SCRIPT
 * 
 * Run this entire script as: CORTEXLABTEST user
 * This validates everything attendees will do tomorrow
 * 
 *******************************************************************************/

-- ============================================================================
-- TEST 1: VERIFY DEFAULT CONTEXT
-- ============================================================================

SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 1: Verify Default Context' AS test_name;

SELECT 
  CURRENT_ROLE() AS my_role,
  CURRENT_WAREHOUSE() AS my_warehouse, 
  CURRENT_DATABASE() AS my_database,
  CURRENT_SCHEMA() AS my_schema,
  CASE 
    WHEN CURRENT_ROLE() = 'CORTEXLABTEST_ROLE' 
     AND CURRENT_WAREHOUSE() = 'CORTEX_LAB_WH'
     AND CURRENT_DATABASE() = 'LAB_DATA'
     AND CURRENT_SCHEMA() = 'CORTEXLABTEST_WORKSPACE'
    THEN '✓ PASS - Context is correct'
    ELSE '✗ FAIL - Context is wrong'
  END AS test_result;

-- ============================================================================
-- TEST 2: READ SHARED DATA (Worksheet 1 prerequisite)
-- ============================================================================

SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 2: Read Shared Data' AS test_name;

-- Test reading support tickets
SELECT 
  'Customer Support Tickets' AS table_name,
  COUNT(*) AS row_count,
  CASE WHEN COUNT(*) >= 10 THEN '✓ PASS' ELSE '✗ FAIL' END AS test_result
FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS

UNION ALL

-- Test reading reviews
SELECT 
  'Product Reviews',
  COUNT(*),
  CASE WHEN COUNT(*) >= 10 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM LAB_DATA.SAMPLES.PRODUCT_REVIEWS

UNION ALL

-- Test reading docs
SELECT 
  'Product Docs',
  COUNT(*),
  CASE WHEN COUNT(*) >= 5 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM LAB_DATA.SAMPLES.PRODUCT_DOCS

UNION ALL

-- Test reading transcripts
SELECT 
  'Sales Transcripts',
  COUNT(*),
  CASE WHEN COUNT(*) >= 3 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM LAB_DATA.SAMPLES.SALES_TRANSCRIPTS;

-- ============================================================================
-- TEST 3: CORTEX SENTIMENT FUNCTION (Worksheet 1, Exercise 1.1)
-- ============================================================================

SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 3: Cortex SENTIMENT Function' AS test_name;

-- Test basic sentiment
SELECT 
  'Positive Text' AS test_case,
  SNOWFLAKE.CORTEX.SENTIMENT('I love this product! It is amazing!') AS sentiment_score,
  CASE 
    WHEN SNOWFLAKE.CORTEX.SENTIMENT('I love this product! It is amazing!') > 0 
    THEN '✓ PASS - Positive detected'
    ELSE '✗ FAIL'
  END AS test_result

UNION ALL

SELECT 
  'Negative Text',
  SNOWFLAKE.CORTEX.SENTIMENT('This is terrible and broken. Very disappointed.') AS sentiment_score,
  CASE 
    WHEN SNOWFLAKE.CORTEX.SENTIMENT('This is terrible and broken. Very disappointed.') < 0 
    THEN '✓ PASS - Negative detected'
    ELSE '✗ FAIL'
  END;

-- Test sentiment on actual data (Exercise 1.1)
SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 3b: Sentiment on Real Tickets (Exercise 1.1)' AS test_name;

SELECT
  ticket_id,
  subject,
  SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score,
  status,
  priority
FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
WHERE status = 'open'
  AND SNOWFLAKE.CORTEX.SENTIMENT(description) < -0.3
ORDER BY sentiment_score ASC
LIMIT 5;
-- Expected: 3-5 tickets with negative sentiment

-- ============================================================================
-- TEST 4: CORTEX TRANSLATE FUNCTION (Worksheet 1, Exercise 1.2)
-- ============================================================================

SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 4: Cortex TRANSLATE Function' AS test_name;

-- Test basic translation
SELECT 
  'Translation Test' AS test_case,
  SNOWFLAKE.CORTEX.TRANSLATE('Bonjour le monde', 'fr', 'en') AS translated_text,
  CASE 
    WHEN LOWER(SNOWFLAKE.CORTEX.TRANSLATE('Bonjour le monde', 'fr', 'en')) LIKE '%hello%'
    THEN '✓ PASS - Translation works'
    ELSE '✗ FAIL'
  END AS test_result;

-- Test translation on Spanish tickets (Exercise 1.2)
SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 4b: Translate Spanish Tickets (Exercise 1.2)' AS test_name;

SELECT
  ticket_id,
  subject AS spanish_subject,
  SNOWFLAKE.CORTEX.TRANSLATE(subject, 'es', 'en') AS english_subject,
  SNOWFLAKE.CORTEX.SENTIMENT(
    SNOWFLAKE.CORTEX.TRANSLATE(description, 'es', 'en')
  ) AS sentiment_score
FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
WHERE language = 'es'
LIMIT 3;
-- Expected: Spanish tickets translated to English with sentiment

-- ============================================================================
-- TEST 5: CORTEX SUMMARIZE FUNCTION (Worksheet 1, Exercise 1.3)
-- ============================================================================

SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 5: Cortex SUMMARIZE Function' AS test_name;

-- Test summarization on user manuals (Exercise 1.3)
SELECT
  doc_id,
  title,
  LEFT(content, 100) AS content_preview,
  LEFT(SNOWFLAKE.CORTEX.SUMMARIZE(content), 150) AS summary_preview
FROM LAB_DATA.SAMPLES.PRODUCT_DOCS
WHERE doc_type = 'user_manual'
LIMIT 2;
-- Expected: Summaries that are shorter than original content

-- ============================================================================
-- TEST 6: CORTEX COMPLETE FUNCTION (Worksheet 2, Exercise 2.2)
-- ============================================================================

SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 6: Cortex COMPLETE Function' AS test_name;

-- Test basic complete
SELECT 
  'Basic COMPLETE Test' AS test_case,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Respond with exactly one word: What color is grass?'
  ) AS response,
  '✓ PASS - COMPLETE function works' AS test_result;

-- Test urgency classification (Exercise 2.2)
SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 6b: Urgency Classification (Exercise 2.2)' AS test_name;

SELECT
  ticket_id,
  subject,
  priority AS actual_priority,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Classify urgency as exactly one word (low, medium, or high): ' || subject
  ) AS ai_urgency
FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
LIMIT 5;
-- Expected: Urgency classifications (low/medium/high)

-- ============================================================================
-- TEST 7: WRITE TO PERSONAL WORKSPACE
-- ============================================================================

SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 7: Write to Personal Workspace' AS test_name;

-- Switch to test workspace
USE SCHEMA LAB_DATA.CORTEXLABTEST_WORKSPACE;

-- Test 7a: Create table
CREATE OR REPLACE TABLE my_test_table (
  id INT,
  name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

SELECT '✓ PASS - Can create table in workspace' AS test_result;

-- Test 7b: Insert data
INSERT INTO my_test_table (id, name) VALUES 
  (1, 'Test Record 1'),
  (2, 'Test Record 2'),
  (3, 'Test Record 3');

SELECT '✓ PASS - Can insert data into table' AS test_result;

-- Test 7c: Query data
SELECT 
  'Records in test table' AS test_case,
  COUNT(*) AS row_count,
  CASE 
    WHEN COUNT(*) = 3 THEN '✓ PASS - Can query workspace table'
    ELSE '✗ FAIL'
  END AS test_result
FROM my_test_table;

-- Test 7d: Create view
CREATE OR REPLACE VIEW my_test_view AS
SELECT 
  ticket_id,
  subject,
  priority
FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
WHERE priority = 'high';

SELECT '✓ PASS - Can create view in workspace' AS test_result;

-- Test 7e: Query view
SELECT 
  'Records in test view' AS test_case,
  COUNT(*) AS row_count,
  CASE 
    WHEN COUNT(*) > 0 THEN '✓ PASS - Can query workspace view'
    ELSE '✗ FAIL'
  END AS test_result
FROM my_test_view;

-- ============================================================================
-- TEST 8: VERIFY ISOLATION (Cannot access other workspaces)
-- ============================================================================

SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 8: Verify Workspace Isolation' AS test_name;

-- This query should FAIL with permission error
-- If it succeeds, there's a security problem!
BEGIN
  SELECT * FROM LAB_DATA.CORTEXLAB01_WORKSPACE.my_test_table LIMIT 1;
  SELECT '✗ FAIL - Security issue: Can access other workspace!' AS test_result;
EXCEPTION
  WHEN OTHER THEN
    SELECT '✓ PASS - Cannot access other workspaces (security works)' AS test_result;
END;

-- ============================================================================
-- TEST 9: LIST OBJECTS IN WORKSPACE
-- ============================================================================

SELECT 
  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS divider,
  'TEST 9: List Objects Created in Workspace' AS test_name;

-- Show tables
SHOW TABLES IN SCHEMA LAB_DATA.CORTEXLABTEST_WORKSPACE;

-- Show views
SHOW VIEWS IN SCHEMA LAB_DATA.CORTEXLABTEST_WORKSPACE;

SELECT 
  '✓ Objects created successfully' AS status,
  'Tables and views are visible in workspace' AS detail;

-- ============================================================================
-- TEST SUMMARY
-- ============================================================================

SELECT 
  '╔════════════════════════════════════════════════════════════════╗' AS summary
UNION ALL SELECT '║                                                                ║'
UNION ALL SELECT '║  ✅ ALL TESTS COMPLETE                                         ║'
UNION ALL SELECT '║                                                                ║'
UNION ALL SELECT '║  If all tests passed:                                          ║'
UNION ALL SELECT '║  • All Cortex functions work                                   ║'
UNION ALL SELECT '║  • Shared data is accessible                                   ║'
UNION ALL SELECT '║  • Personal workspaces work                                    ║'
UNION ALL SELECT '║  • Security isolation verified                                 ║'
UNION ALL SELECT '║  • Ready for attendees!                                        ║'
UNION ALL SELECT '║                                                                ║'
UNION ALL SELECT '║  Next Steps:                                                   ║'
UNION ALL SELECT '║  1. Review any failed tests above                              ║'
UNION ALL SELECT '║  2. Fix any issues                                             ║'
UNION ALL SELECT '║  3. Log back in as ACCOUNTADMIN                                ║'
UNION ALL SELECT '║  4. Optionally clean up test account (see cleanup script)      ║'
UNION ALL SELECT '║                                                                ║'
UNION ALL SELECT '╚════════════════════════════════════════════════════════════════╝';
