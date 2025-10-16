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
*/

-- STEP 1: Run this query to see basic sentiment analysis
SELECT 
  ticket_id,
  subject,
  SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score
FROM CUSTOMER_SUPPORT_TICKETS
LIMIT 5;

-- STEP 2: Now let's categorize tickets by sentiment
-- TODO: Fill in the CASE statement to categorize sentiment scores
SELECT 
  ticket_id,
  subject,
  SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score,
  CASE 
    WHEN SNOWFLAKE.CORTEX.SENTIMENT(description) > 0.5 THEN 'Positive'
    WHEN SNOWFLAKE.CORTEX.SENTIMENT(description) < -0.5 THEN 'Negative'
    ELSE 'Neutral'
  END AS sentiment_category,
  status,
  priority
FROM CUSTOMER_SUPPORT_TICKETS
ORDER BY sentiment_score ASC;  -- Most negative first

-- QUESTION: Which ticket is most negative? Does its priority match the sentiment?

-- STEP 3: YOUR TURN - Find all open tickets with negative sentiment
-- TODO: Add a WHERE clause to filter for open tickets with sentiment < -0.3
SELECT 
  ticket_id,
  subject,
  SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score,
  status,
  priority
FROM CUSTOMER_SUPPORT_TICKETS
-- TODO: Add your WHERE clause here
WHERE status = 'open' 
  AND SNOWFLAKE.CORTEX.SENTIMENT(description) < -0.3
ORDER BY sentiment_score ASC;

-- ============================================================================
-- EXERCISE 1.2: TRANSLATION
-- Make global support accessible in any language
-- ============================================================================

/*
  SCENARIO: You have customers writing in multiple languages, but your 
  support team primarily speaks English. You need to translate incoming tickets.
  
  TRANSLATE function syntax: TRANSLATE(text, source_language, target_language)
*/

-- STEP 1: See what languages we have in our tickets
SELECT DISTINCT 
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
-- TODO: Complete this query to translate Spanish tickets and get their sentiment
SELECT 
  ticket_id,
  subject AS spanish_subject,
  SNOWFLAKE.CORTEX.TRANSLATE(subject, 'es', 'en') AS english_subject,
  -- TODO: Add SENTIMENT analysis on the TRANSLATED English text
  SNOWFLAKE.CORTEX.SENTIMENT(
    SNOWFLAKE.CORTEX.TRANSLATE(description, 'es', 'en')
  ) AS sentiment_score
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
-- TODO: Create summaries for all documents of type 'user_manual'
SELECT 
  doc_id,
  title,
  -- TODO: Add SUMMARIZE function here
  SNOWFLAKE.CORTEX.SUMMARIZE(content) AS summary
FROM PRODUCT_DOCS
WHERE doc_type = 'user_manual';

-- BONUS CHALLENGE: Summarize sales call transcripts
-- TODO: Write a query to summarize the sales transcripts and identify the outcome
SELECT 
  call_id,
  sales_rep,
  customer_name,
  call_duration_minutes,
  outcome,
  SNOWFLAKE.CORTEX.SUMMARIZE(transcript) AS call_summary
FROM SALES_TRANSCRIPTS
ORDER BY call_duration_minutes DESC;

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

-- STEP 1: The complete multi-function query
SELECT 
  ticket_id,
  language,
  country,
  priority,
  created_date,
  -- Original subject
  subject AS original_subject,
  -- Translated subject (only if not English)
  CASE 
    WHEN language = 'en' THEN subject
    ELSE SNOWFLAKE.CORTEX.TRANSLATE(subject, language, 'en')
  END AS english_subject,
  -- Sentiment analysis
  SNOWFLAKE.CORTEX.SENTIMENT(
    CASE 
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END
  ) AS sentiment_score,
  -- Summary of the issue
  SNOWFLAKE.CORTEX.SUMMARIZE(
    CASE 
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END
  ) AS issue_summary
FROM CUSTOMER_SUPPORT_TICKETS
WHERE status = 'open'
ORDER BY sentiment_score ASC
LIMIT 10;

-- STEP 2: YOUR TURN - Create a product review analysis
-- TODO: Analyze product reviews with rating, sentiment, and summary
-- Hint: Translate reviews to English first if needed
SELECT 
  review_id,
  product_name,
  rating,
  language,
  -- TODO: Translate review_text to English if not already English
  CASE 
    WHEN language = 'en' THEN review_text
    ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
  END AS english_review,
  -- TODO: Get sentiment score
  SNOWFLAKE.CORTEX.SENTIMENT(
    CASE 
      WHEN language = 'en' THEN review_text
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
    END
  ) AS sentiment_score,
  -- TODO: Create a summary
  SNOWFLAKE.CORTEX.SUMMARIZE(
    CASE 
      WHEN language = 'en' THEN review_text
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
    END
  ) AS review_summary
FROM PRODUCT_REVIEWS
ORDER BY rating ASC;

-- QUESTION: Do the sentiment scores align with the star ratings? 
-- When might they differ?

/*******************************************************************************
 * WORKSHEET 1 COMPLETE! ✓
 * 
 * KEY TAKEAWAYS:
 * - Cortex functions are just SQL - no Python, no APIs, no complexity
 * - SENTIMENT helps prioritize customer issues
 * - TRANSLATE breaks down language barriers
 * - SUMMARIZE condenses information for quick understanding
 * - Functions can be combined and nested for powerful workflows
 * 
 * NEXT: Move to Worksheet 2 to learn about CORTEX.COMPLETE and advanced LLM usage
 *******************************************************************************/