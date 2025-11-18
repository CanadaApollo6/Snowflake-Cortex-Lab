/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - WORKSHEET 1
 * CORTEX LLM FUNCTIONS: The Building Blocks
 * 
 * Time: 15 minutes
 * Difficulty: Beginner
 * 
 * In this worksheet, you'll learn to use Snowflake's built-in Cortex functions
 * for sentiment analysis, translation, and summarization - all with simple SQL.
 * 
 * LEARNING OBJECTIVES:
 * - Use SENTIMENT to analyze text emotion
 * - Use TRANSLATE to convert text between languages
 * - Use SUMMARIZE to condense long content
 * - Combine multiple Cortex functions in a single query
 * 
 *******************************************************************************/

USE ROLE CORTEX_LAB_USER;
USE WAREHOUSE CORTEX_LAB_WH;
USE DATABASE LAB_DATA;
USE SCHEMA SAMPLES;

-- ============================================================================
-- EXERCISE 1.1: SENTIMENT ANALYSIS
-- Understand customer emotions from support tickets
-- ============================================================================

/*
  SCENARIO: You're a customer support manager who needs to identify 
  urgent negative tickets that need immediate attention.
  
  The SENTIMENT function returns a score from -1 (very negative) to +1 (very positive)
  
  SYNTAX: SNOWFLAKE.CORTEX.SENTIMENT(text_column)
*/

-- STEP 1: Run this query to see basic sentiment analysis
SELECT 
  ticket_id,
  subject,
  SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score
FROM CUSTOMER_SUPPORT_TICKETS
LIMIT 5;

-- STEP 2: Now let's categorize tickets by sentiment
-- This uses a subquery to avoid calling SENTIMENT multiple times
SELECT 
  ticket_id,
  subject,
  sentiment_score,
  CASE 
    WHEN sentiment_score > 0.5 THEN 'Positive'
    WHEN sentiment_score < -0.5 THEN 'Negative'
    ELSE 'Neutral'
  END AS sentiment_category,
  status,
  priority
FROM (
  SELECT 
    ticket_id,
    subject,
    SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score,
    status,
    priority
  FROM CUSTOMER_SUPPORT_TICKETS
)
ORDER BY sentiment_score ASC;  -- Most negative first

-- QUESTION: Which ticket is most negative? Does its priority match the sentiment?

-- STEP 3: YOUR TURN - Find all open tickets with negative sentiment
-- TODO: Complete this query to filter for:
--       - status = 'open'
--       - sentiment_score < -0.3
-- HINT: Use a subquery pattern like Step 2 to avoid calling SENTIMENT twice

SELECT 
  ticket_id,
  subject,
  sentiment_score,
  status,
  priority
FROM (
  SELECT 
    ticket_id,
    subject,
    SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score,
    status,
    priority
  FROM CUSTOMER_SUPPORT_TICKETS
)
WHERE -- TODO: Add your filter conditions here


ORDER BY sentiment_score ASC;

-- ============================================================================
-- EXERCISE 1.2: TRANSLATION
-- Make global support accessible in any language
-- ============================================================================

/*
  SCENARIO: You have customers writing in multiple languages, but your 
  support team primarily speaks English. You need to translate incoming tickets.
  
  SYNTAX: SNOWFLAKE.CORTEX.TRANSLATE(text, source_language, target_language)
  
  Common language codes: 'en' (English), 'es' (Spanish), 'fr' (French), 
                        'de' (German), 'ja' (Japanese), 'zh' (Chinese)
*/

-- STEP 1: See what languages we have in our tickets
SELECT 
  language,
  COUNT(*) AS ticket_count
FROM CUSTOMER_SUPPORT_TICKETS
GROUP BY language
ORDER BY ticket_count DESC;

-- STEP 2: Translate non-English tickets to English
SELECT 
  ticket_id,
  language AS original_language,
  subject AS original_subject,
  SNOWFLAKE.CORTEX.TRANSLATE(subject, language, 'en') AS english_subject,
  LEFT(description, 150) AS original_description_preview,
  SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en') AS english_description
FROM CUSTOMER_SUPPORT_TICKETS
WHERE language != 'en';

-- STEP 3: YOUR TURN - Translate AND analyze sentiment on Spanish tickets
-- TODO: Complete this query to:
--       1. Translate Spanish subject and description to English
--       2. Analyze sentiment on the TRANSLATED English description
-- HINT: You can nest functions like: SENTIMENT(TRANSLATE(...))

SELECT 
  ticket_id,
  subject AS spanish_subject,
  -- TODO: Translate subject from Spanish to English
  
  -- TODO: Translate description from Spanish to English, then analyze sentiment
  
FROM CUSTOMER_SUPPORT_TICKETS
WHERE language = 'es';

-- INSIGHT: Notice how you can NEST Cortex functions! 
-- The translated text becomes input for sentiment analysis.

-- ============================================================================
-- EXERCISE 1.3: SUMMARIZATION
-- Turn long content into concise summaries
-- ============================================================================

/*
  SCENARIO: Your product documentation is lengthy. You want to create 
  quick summaries for your support team to reference during calls.
  
  SYNTAX: SNOWFLAKE.CORTEX.SUMMARIZE(text_column)
  
  SUMMARIZE automatically condenses text while preserving key information.
*/

-- STEP 1: See how long our documentation is
SELECT 
  doc_id,
  title,
  LENGTH(content) AS character_count,
  ROUND(LENGTH(content) / 500, 1) AS estimated_reading_minutes
FROM PRODUCT_DOCS
ORDER BY character_count DESC;

-- STEP 2: Summarize a long troubleshooting guide
SELECT 
  doc_id,
  title,
  LENGTH(content) AS original_length,
  content AS original_content,
  SNOWFLAKE.CORTEX.SUMMARIZE(content) AS summary,
  LENGTH(SNOWFLAKE.CORTEX.SUMMARIZE(content)) AS summary_length,
  ROUND(
    (LENGTH(SNOWFLAKE.CORTEX.SUMMARIZE(content)) * 100.0) / LENGTH(content), 
    1
  ) AS compression_percentage
FROM PRODUCT_DOCS
WHERE doc_id = 'DOC-004'  -- SmartCam troubleshooting guide
LIMIT 1;

-- STEP 3: YOUR TURN - Summarize all user manuals
-- TODO: Complete this query to create summaries for all documents 
--       where doc_type = 'user_manual'
-- HINT: Use the SUMMARIZE function on the content column

SELECT 
  doc_id,
  title,
  -- TODO: Add SUMMARIZE function here to create summary of content

FROM PRODUCT_DOCS
WHERE -- TODO: Add filter for user_manual document type
;

-- BONUS CHALLENGE: Summarize sales call transcripts
-- TODO: Write a complete query to:
--       - Select call_id, sales_rep, customer_name, call_duration_minutes, outcome
--       - Summarize the transcript column
--       - Order by call_duration_minutes DESC
-- HINT: Look at the SALES_TRANSCRIPTS table structure

-- TODO: Write your query here


-- ============================================================================
-- EXERCISE 1.4: COMBINING MULTIPLE CORTEX FUNCTIONS
-- Real-world scenarios often need multiple AI capabilities together
-- ============================================================================

/*
  SCENARIO: You want a dashboard showing:
  1. Non-English tickets translated to English
  2. Their sentiment scores
  3. A summary of the issue
  
  This is a common pattern: TRANSLATE → SENTIMENT → SUMMARIZE
*/

-- STEP 1: The complete multi-function query (example provided)
-- Study this pattern - you'll apply it in Step 2
SELECT 
  ticket_id,
  language,
  country,
  priority,
  created_date,
  subject AS original_subject,
  -- Translate subject only if not English
  CASE 
    WHEN language = 'en' THEN subject
    ELSE SNOWFLAKE.CORTEX.TRANSLATE(subject, language, 'en')
  END AS english_subject,
  -- Get sentiment and summary from subquery to avoid recalculating translation
  sentiment_score,
  issue_summary
FROM (
  SELECT 
    ticket_id,
    language,
    country,
    priority,
    created_date,
    subject,
    -- Translate description once
    CASE 
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END AS english_description
  FROM CUSTOMER_SUPPORT_TICKETS
  WHERE status = 'open'
),
-- Calculate sentiment and summary from the already-translated text
LATERAL (
  SELECT 
    SNOWFLAKE.CORTEX.SENTIMENT(english_description) AS sentiment_score,
    SNOWFLAKE.CORTEX.SUMMARIZE(english_description) AS issue_summary
)
ORDER BY sentiment_score ASC
LIMIT 10;

-- STEP 2: YOUR TURN - Create a product review analysis
-- TODO: Build a complete query to analyze product reviews with:
--       - review_id, product_name, rating, language
--       - Translated review text (to English if needed)
--       - Sentiment score of the review
--       - Summary of the review
-- 
-- REQUIREMENTS:
-- - Use the PRODUCT_REVIEWS table
-- - Translate non-English reviews to English first
-- - Calculate sentiment on the English version
-- - Create a summary of the English version
-- - Order by rating ASC to see worst reviews first
--
-- HINT: Follow the pattern from Step 1 using subqueries to avoid
--       translating the same text multiple times

-- TODO: Write your complete query here




-- QUESTION: Do the sentiment scores align with the star ratings? 
-- When might they differ?
-- 
-- Consider these scenarios:
-- - Sarcastic reviews ("Great! It broke after 2 days..." = positive words, negative meaning)
-- - Mixed reviews (love product features, hate shipping/price)
-- - Cultural differences in expressing satisfaction
-- - Brief vs detailed reviews

/*******************************************************************************
 * WORKSHEET 1 COMPLETE! ✓
 * 
 * KEY TAKEAWAYS:
 * - Cortex functions are just SQL - no Python, no APIs, no complexity
 * - SENTIMENT helps prioritize customer issues (-1 to +1 scale)
 * - TRANSLATE breaks down language barriers (supports 100+ languages)
 * - SUMMARIZE condenses information for quick understanding
 * - Functions can be combined and nested for powerful workflows
 * - Use subqueries to avoid calling expensive functions multiple times
 * 
 * PERFORMANCE TIP:
 * When using Cortex functions in both SELECT and WHERE clauses, or multiple
 * times in the same query, use subqueries to calculate once and reuse the result.
 * 
 * NEXT: Move to Worksheet 2 to learn about CORTEX.COMPLETE and advanced LLM usage
 *******************************************************************************/

-- ============================================================================
-- OPTIONAL: CHECK YOUR WORK
-- Run these verification queries to test your solutions
-- ============================================================================

-- Verify Exercise 1.1 Step 3: Should return 3-5 tickets
-- SELECT COUNT(*) AS open_negative_tickets 
-- FROM (your Exercise 1.1 Step 3 query);
-- Expected: Between 3-5 tickets

-- Verify Exercise 1.3 Step 3: Should return 5 summaries
-- SELECT COUNT(*) AS user_manual_count 
-- FROM (your Exercise 1.3 Step 3 query);
-- Expected: Exactly 5 documents

-- Verify Exercise 1.4 Step 2: Should return 15 reviews
-- SELECT COUNT(*) AS total_reviews
-- FROM (your Exercise 1.4 Step 2 query);
-- Expected: Exactly 15 reviews
