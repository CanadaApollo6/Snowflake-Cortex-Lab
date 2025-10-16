/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - WORKSHEET 1 ANSWER KEY
 * CORTEX LLM FUNCTIONS: The Building Blocks
 *
 * This file contains complete solutions for all TODO exercises in Worksheet 1.
 * Use this to verify your answers or for instructor reference.
 *
 *******************************************************************************/

USE ROLE CORTEX_LAB_USER;
USE WAREHOUSE CORTEX_LAB_WH;
USE DATABASE LAB_DATA;
USE SCHEMA SAMPLES;

-- ============================================================================
-- EXERCISE 1.1: SENTIMENT ANALYSIS
-- ============================================================================

-- STEP 3: YOUR TURN - Find all open tickets with negative sentiment
-- ANSWER:
SELECT
  ticket_id,
  subject,
  SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score,
  status,
  priority
FROM CUSTOMER_SUPPORT_TICKETS
WHERE status = 'open'
  AND SNOWFLAKE.CORTEX.SENTIMENT(description) < -0.3
ORDER BY sentiment_score ASC;

/*
EXPLANATION:
- We filter for status = 'open' to get only open tickets
- We use SENTIMENT function in WHERE clause to filter for negative sentiment
- Threshold of -0.3 catches moderately to very negative tickets
- ORDER BY sentiment_score ASC shows most negative first

EXPECTED RESULTS:
You should see tickets like:
- TKT-001 (damaged package) - very negative
- TKT-004 (payment problem) - frustrated
- TKT-005 (defective product) - frustrated
- TKT-006 (wrong item) - annoyed
*/

-- ============================================================================
-- EXERCISE 1.2: TRANSLATION
-- ============================================================================

-- STEP 3: YOUR TURN - Translate AND analyze sentiment on Spanish tickets
-- ANSWER:
SELECT
  ticket_id,
  subject AS spanish_subject,
  SNOWFLAKE.CORTEX.TRANSLATE(subject, 'es', 'en') AS english_subject,
  SNOWFLAKE.CORTEX.SENTIMENT(
    SNOWFLAKE.CORTEX.TRANSLATE(description, 'es', 'en')
  ) AS sentiment_score
FROM CUSTOMER_SUPPORT_TICKETS
WHERE language = 'es';

/*
EXPLANATION:
- TRANSLATE converts Spanish text to English
- We nest TRANSLATE inside SENTIMENT to analyze the translated text
- This is a common pattern: translate first, then analyze

EXPECTED RESULTS:
TKT-004: "Problema con el pago" → "Problem with payment"
Sentiment should be negative (frustrated customer)

KEY INSIGHT:
Notice we can nest Cortex functions! The output of TRANSLATE becomes
the input for SENTIMENT. This is powerful for multi-language analysis.
*/

-- ============================================================================
-- EXERCISE 1.3: SUMMARIZATION
-- ============================================================================

-- STEP 3: YOUR TURN - Summarize all user manuals
-- ANSWER:
SELECT
  doc_id,
  title,
  SNOWFLAKE.CORTEX.SUMMARIZE(content) AS summary
FROM PRODUCT_DOCS
WHERE doc_type = 'user_manual';

/*
EXPLANATION:
- Simple filter by doc_type = 'user_manual'
- SUMMARIZE condenses each document while preserving key info
- No additional parameters needed - Snowflake handles the summarization

EXPECTED RESULTS:
You should see summaries for:
- DOC-001: UltraSound Pro setup (charging, pairing, ANC)
- DOC-003: PowerBook Elite setup (unboxing, first boot, battery tips)
- DOC-004: FitTrack features (health tracking, exercise modes, battery)

Each summary should be 20-30% of the original length.
*/

-- BONUS CHALLENGE: Summarize sales call transcripts
-- ANSWER:
SELECT
  call_id,
  sales_rep,
  customer_name,
  call_duration_minutes,
  outcome,
  SNOWFLAKE.CORTEX.SUMMARIZE(transcript) AS call_summary
FROM SALES_TRANSCRIPTS
ORDER BY call_duration_minutes DESC;

/*
EXPECTED RESULTS:
CALL-001: Summary about PowerBook Elite discussion, 15 laptops needed,
          customer wants quote for both standard and Pro models
CALL-002: Summary about FitTrack watches for fitness center,
          50 units ordered with custom branding

KEY INSIGHT:
Summaries preserve the most important information: products discussed,
quantities, next steps, and outcomes.
*/

-- ============================================================================
-- EXERCISE 1.4: COMBINING MULTIPLE CORTEX FUNCTIONS
-- ============================================================================

-- STEP 2: YOUR TURN - Create a product review analysis
-- ANSWER:
SELECT
  review_id,
  product_name,
  rating,
  language,
  -- Translate review_text to English if not already English
  CASE
    WHEN language = 'en' THEN review_text
    ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
  END AS english_review,
  -- Get sentiment score
  SNOWFLAKE.CORTEX.SENTIMENT(
    CASE
      WHEN language = 'en' THEN review_text
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
    END
  ) AS sentiment_score,
  -- Create a summary
  SNOWFLAKE.CORTEX.SUMMARIZE(
    CASE
      WHEN language = 'en' THEN review_text
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
    END
  ) AS review_summary
FROM PRODUCT_REVIEWS
ORDER BY rating ASC;

/*
EXPLANATION:
- We use CASE statements to avoid translating English reviews unnecessarily
- Same CASE logic is repeated for sentiment and summarization
- This ensures we always work with English text for analysis
- ORDER BY rating ASC shows lowest-rated reviews first

EXPECTED RESULTS:
You should see:
- 1-star reviews with negative sentiment scores (around -0.7 to -0.9)
- 5-star reviews with positive sentiment scores (around +0.7 to +0.9)
- Sentiment scores generally align with star ratings

QUESTION: Do sentiment scores align with star ratings?
ANSWER: Generally yes, but not always perfectly! Here's why:
- A 3-star review might have neutral sentiment (customer is "meh")
- A 4-star review might have positive sentiment but mention minor issues
- Sentiment analyzes the emotional tone of the text
- Rating is the customer's overall judgment
- Sometimes these diverge! Example: "Great product but too expensive"
  might have positive sentiment but only 3 stars due to price
*/

-- ============================================================================
-- ALTERNATIVE SOLUTIONS & VARIATIONS
-- ============================================================================

-- VARIATION 1: More efficient review analysis (avoiding repeated CASE)
-- Using a CTE to translate once:
WITH translated_reviews AS (
  SELECT
    review_id,
    product_name,
    rating,
    language,
    CASE
      WHEN language = 'en' THEN review_text
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
    END AS english_text
  FROM PRODUCT_REVIEWS
)
SELECT
  review_id,
  product_name,
  rating,
  language,
  english_text AS english_review,
  SNOWFLAKE.CORTEX.SENTIMENT(english_text) AS sentiment_score,
  SNOWFLAKE.CORTEX.SUMMARIZE(english_text) AS review_summary
FROM translated_reviews
ORDER BY rating ASC;

/*
ADVANTAGE: Cleaner code, only translate once
DISADVANTAGE: Slightly more complex with CTE
BOTH APPROACHES ARE CORRECT!
*/

-- ============================================================================
-- KEY TAKEAWAYS FOR WORKSHEET 1
-- ============================================================================

/*
1. SENTIMENT returns scores from -1 (negative) to +1 (positive)
   - Use thresholds like -0.3 or +0.5 to categorize
   - Can be used in WHERE clauses for filtering

2. TRANSLATE supports 100+ languages
   - Syntax: TRANSLATE(text, source_lang, target_lang)
   - Use ISO language codes: 'es', 'fr', 'de', 'ja', 'zh', etc.

3. SUMMARIZE condenses text intelligently
   - Preserves key information
   - Works on any text length
   - Typically reduces to 20-30% of original

4. FUNCTIONS CAN BE NESTED AND COMBINED
   - Common pattern: TRANSLATE → SENTIMENT
   - Use CASE statements to avoid unnecessary work
   - Can use Cortex functions in WHERE, SELECT, and ORDER BY

5. NO EXTERNAL APIS OR PYTHON NEEDED
   - Everything is SQL
   - No model deployment required
   - Scales automatically

NEXT: Move to Worksheet 2 for CORTEX.COMPLETE and advanced LLM usage!
*/
