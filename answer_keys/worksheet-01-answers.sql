/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - WORKSHEET 1 ANSWER KEY
 * CORTEX LLM FUNCTIONS: The Building Blocks
 *
 * This file contains complete, optimized solutions for all exercises in Worksheet 1.
 * Use this to verify your answers or for instructor reference.
 *
 * PERFORMANCE NOTE: These solutions use subqueries to avoid calling expensive
 * Cortex functions multiple times in the same query.
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
-- OPTIMIZED ANSWER:
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
WHERE status = 'open' 
  AND sentiment_score < -0.3
ORDER BY sentiment_score ASC;

/*
WHY THIS IS OPTIMAL:
- Uses subquery to calculate SENTIMENT once and reuse the result
- Avoids calling SENTIMENT function twice (once for SELECT, once for WHERE)
- More efficient and potentially lower cost

ALTERNATIVE (ACCEPTABLE BUT LESS EFFICIENT):
WHERE status = 'open' AND SNOWFLAKE.CORTEX.SENTIMENT(description) < -0.3

This works but may call SENTIMENT twice. The optimizer might cache it, but
the subquery pattern is more explicit and guaranteed to be efficient.

EXPECTED RESULTS:
You should see 3-5 tickets including:
- TKT-001 (damaged package) - sentiment around -0.8 to -0.9 (very negative)
- TKT-004 (payment problem) - sentiment around -0.5 to -0.7 (frustrated)
- TKT-006 (defective product) - sentiment around -0.7 to -0.8 (frustrated)
- TKT-008 (wrong item) - sentiment around -0.6 to -0.7 (annoyed)

KEY INSIGHT:
Notice that priority doesn't always match sentiment! A ticket might be set
to 'medium' priority but have very negative sentiment. This is why automated
sentiment analysis is valuable - it can help identify tickets that need
immediate attention regardless of their assigned priority.
*/

-- ============================================================================
-- EXERCISE 1.2: TRANSLATION
-- ============================================================================

-- STEP 3: YOUR TURN - Translate AND analyze sentiment on Spanish tickets
-- OPTIMIZED ANSWER:
SELECT 
  ticket_id,
  subject AS spanish_subject,
  english_subject,
  sentiment_score
FROM (
  SELECT
    ticket_id,
    subject,
    SNOWFLAKE.CORTEX.TRANSLATE(subject, 'es', 'en') AS english_subject,
    SNOWFLAKE.CORTEX.TRANSLATE(description, 'es', 'en') AS english_description
  FROM CUSTOMER_SUPPORT_TICKETS
  WHERE language = 'es'
),
LATERAL (
  SELECT 
    SNOWFLAKE.CORTEX.SENTIMENT(english_description) AS sentiment_score
)
ORDER BY sentiment_score ASC;

/*
WHY THIS IS OPTIMAL:
- Translates each text field only once
- Uses LATERAL join to calculate sentiment from already-translated text
- Avoids nested function calls that would retranslate the same text

SIMPLER ALTERNATIVE (ALSO ACCEPTABLE):
SELECT
  ticket_id,
  subject AS spanish_subject,
  SNOWFLAKE.CORTEX.TRANSLATE(subject, 'es', 'en') AS english_subject,
  SNOWFLAKE.CORTEX.SENTIMENT(
    SNOWFLAKE.CORTEX.TRANSLATE(description, 'es', 'en')
  ) AS sentiment_score
FROM CUSTOMER_SUPPORT_TICKETS
WHERE language = 'es';

This is clearer for beginners but calls TRANSLATE twice on description
(once for SENTIMENT, and Snowflake may need to evaluate it again).

EXPECTED RESULTS:
Two Spanish tickets:
- TKT-004: "Problema con el pago" → "Problem with payment"
  Sentiment: Negative (around -0.5 to -0.6) - frustrated about payment failure
  
- TKT-005: "Consulta sobre envío internacional" → "International shipping inquiry"
  Sentiment: Neutral to slightly positive (around 0 to +0.2) - polite question

KEY INSIGHT:
This demonstrates a powerful pattern: TRANSLATE → ANALYZE. You can now
analyze customer sentiment regardless of language! This enables:
- Global customer support
- Multilingual sentiment tracking
- Unified reporting across languages
- Priority routing regardless of language
*/

-- ============================================================================
-- EXERCISE 1.3: SUMMARIZATION
-- ============================================================================

-- STEP 3: YOUR TURN - Summarize all user manuals
-- ANSWER:
SELECT
  doc_id,
  title,
  LENGTH(content) AS original_length,
  SNOWFLAKE.CORTEX.SUMMARIZE(content) AS summary,
  LENGTH(SNOWFLAKE.CORTEX.SUMMARIZE(content)) AS summary_length,
  ROUND(
    (LENGTH(SNOWFLAKE.CORTEX.SUMMARIZE(content)) * 100.0) / LENGTH(content),
    1
  ) AS compression_percent
FROM PRODUCT_DOCS
WHERE doc_type = 'user_manual'
ORDER BY doc_id;

/*
EXPLANATION:
- Simple filter by doc_type = 'user_manual'
- SUMMARIZE condenses each document while preserving key info
- Added length calculations to show compression ratio

EXPECTED RESULTS (5 user manuals):
- DOC-001: UltraSound Pro - Getting Started
  Summary: Covers unboxing, charging (2 hours initial, 30 hours playback),
  pairing steps, and auto-reconnect feature
  
- DOC-002: UltraSound Pro - Noise Cancellation
  Summary: Explains ANC modes (noise cancellation, transparency, off),
  usage tips, battery impact, and best practices
  
- DOC-003: SmartCam 4K - Installation Guide
  Summary: Location selection, Wi-Fi setup, mounting, and motion detection
  configuration with AI features
  
- DOC-005: PowerBook Elite - First Time Setup
  Summary: Unboxing, first boot wizard, security settings, battery optimization,
  and performance tips for the i7/16GB/512GB configuration
  
- DOC-006: FitTrack Smart Watch - Features Overview
  Summary: Health tracking (heart rate, steps, sleep, calories), 20+ exercise
  modes, smart features (notifications, music), 5-7 day battery, 5ATM water resistance

COMPRESSION RATIO:
Typically reduces documents to 15-30% of original length while preserving
all key information. Longer documents often have higher compression ratios.

NOTE ON PERFORMANCE:
We're calling SUMMARIZE multiple times for length calculation. In production,
you might want to use a CTE:

WITH summaries AS (
  SELECT
    doc_id,
    title,
    content,
    SNOWFLAKE.CORTEX.SUMMARIZE(content) AS summary
  FROM PRODUCT_DOCS
  WHERE doc_type = 'user_manual'
)
SELECT
  doc_id,
  title,
  LENGTH(content) AS original_length,
  summary,
  LENGTH(summary) AS summary_length,
  ROUND((LENGTH(summary) * 100.0) / LENGTH(content), 1) AS compression_percent
FROM summaries;
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
CALL-003 (41 min, closed_won):
Summary: Maria Rodriguez discusses FitTrack smartwatches with Downtown Fitness.
Customer orders 50 watches with custom gym branding for premium membership program.
3-4 week delivery timeline. Maria is dedicated account manager.

CALL-001 (32 min, proposal_sent):
Summary: Jennifer Martinez discusses PowerBook Elite laptops with ABC Corp for
dev team. Customer needs 15 units. Jennifer recommends Elite Pro (32GB RAM) for
VMs/containers. Quote to include both models with 3-year warranty and 15% discount.

CALL-004 (25 min, follow_up_scheduled):
Summary: Robert Chen reaches out to Tech Startup Inc about office tech after
Series A funding. Customer has existing vendors but interested in lease options
for 30 laptops. Follow-up scheduled for next week with proposal.

CALL-002 (18 min, lost_to_competitor):
Summary: David Park follows up on SmartCam inquiry. Customer already purchased
cheaper SecureView cameras for small office. David explains AI features and
trade-in program for future consideration.

KEY INSIGHTS:
- Summaries preserve critical details: names, products, quantities, next steps
- Outcome is reflected in summary tone and content
- Longer calls generally contain more detailed discussions
- Can be used for CRM updates, training, or follow-up prioritization
*/

-- ============================================================================
-- EXERCISE 1.4: COMBINING MULTIPLE CORTEX FUNCTIONS
-- ============================================================================

-- STEP 2: YOUR TURN - Create a product review analysis
-- MOST OPTIMIZED ANSWER (Production-ready):
SELECT
  review_id,
  product_name,
  rating,
  language,
  english_review,
  sentiment_score,
  review_summary,
  -- Compare sentiment to rating
  CASE 
    WHEN rating >= 4 AND sentiment_score < 0 THEN 'MISMATCH: High rating but negative sentiment'
    WHEN rating <= 2 AND sentiment_score > 0 THEN 'MISMATCH: Low rating but positive sentiment'
    ELSE 'Aligned'
  END AS rating_sentiment_alignment
FROM (
  -- First translate all non-English reviews
  SELECT
    review_id,
    product_name,
    rating,
    language,
    CASE
      WHEN language = 'en' THEN review_text
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
    END AS english_review
  FROM PRODUCT_REVIEWS
),
-- Then calculate sentiment and summary from the translated text
LATERAL (
  SELECT 
    SNOWFLAKE.CORTEX.SENTIMENT(english_review) AS sentiment_score,
    SNOWFLAKE.CORTEX.SUMMARIZE(english_review) AS review_summary
)
ORDER BY rating ASC, sentiment_score ASC;

/*
WHY THIS IS OPTIMAL:
- Translates each review ONCE (not three times)
- Uses LATERAL join to calculate sentiment and summary from already-translated text
- Avoids nested function calls
- More efficient, especially with large datasets
- Adds alignment check to flag interesting cases

SIMPLER ALTERNATIVE (Acceptable for learning/small datasets):
SELECT
  review_id,
  product_name,
  rating,
  language,
  CASE
    WHEN language = 'en' THEN review_text
    ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
  END AS english_review,
  SNOWFLAKE.CORTEX.SENTIMENT(
    CASE
      WHEN language = 'en' THEN review_text
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
    END
  ) AS sentiment_score,
  SNOWFLAKE.CORTEX.SUMMARIZE(
    CASE
      WHEN language = 'en' THEN review_text
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
    END
  ) AS review_summary
FROM PRODUCT_REVIEWS
ORDER BY rating ASC;

This is clearer and easier to understand but less efficient because it
may translate the same text multiple times.

BOTH APPROACHES ARE CORRECT - choose based on:
- Team skill level (simpler version easier to maintain)
- Dataset size (optimized version better for large datasets)
- Performance requirements (optimized version uses fewer credits)

EXPECTED RESULTS:
15 reviews with ratings 1-5 stars across 5 products:

1-STAR REVIEWS (Very Negative Sentiment):
- REV-009: FitTrack broke after 2 weeks
  Sentiment: -0.9 (extremely negative - "disappointed and angry")
  Summary: Watch stopped working after 2 weeks, unhelpful customer service
  
- REV-010: QuickCharge defective (Japanese review)
  Sentiment: -0.85 (extremely negative)
  Summary: Power bank failed after 1 week, slow refund response

2-STAR REVIEWS (Negative Sentiment):
- REV-007: QuickCharge doesn't charge as advertised
  Sentiment: -0.6 (negative)
  Summary: Battery capacity overstated, slow charging, cheap build quality
  
- REV-008: PowerBook Elite disappointing (Japanese review)
  Sentiment: -0.5 (negative)
  Summary: Slow performance, poor battery life, overpriced

3-STAR REVIEWS (Neutral/Mixed Sentiment):
- REV-005: FitTrack decent but not great
  Sentiment: 0 to -0.2 (neutral to slightly negative)
  Summary: Adequate tracking but short battery, app crashes, scratches easily
  
- REV-006: SmartCam good but connection issues (German review)
  Sentiment: 0 to +0.2 (neutral to slightly positive)
  Summary: Good image quality but WiFi drops, needs restarts

4-STAR REVIEWS (Positive Sentiment):
- REV-003: PowerBook Elite great with minor issues
  Sentiment: +0.6 (positive)
  Summary: Excellent performance, loud fan only complaint
  
- REV-004: UltraSound Pro good but expensive (French review)
  Sentiment: +0.5 (positive)
  Summary: Excellent sound quality and comfort, high price justified
  
- REV-012: SmartCam good value
  Sentiment: +0.5 (positive)
  Summary: Impressive 4K, good night vision, overly sensitive motion detection

5-STAR REVIEWS (Very Positive Sentiment):
- REV-001: UltraSound Pro best ever
  Sentiment: +0.9 (extremely positive - "absolutely incredible")
  Summary: Perfect noise cancellation, days of battery, crisp sound
  
- REV-002: SmartCam excellent (Spanish review)
  Sentiment: +0.85 (extremely positive)
  Summary: Exceptional image quality, easy setup, great value
  
- REV-011: UltraSound Pro excellent value (Chinese review)
  Sentiment: +0.8 (very positive)
  Summary: Outstanding sound quality, effective noise cancellation, comfortable
  
- REV-013: PowerBook Elite perfect for developers
  Sentiment: +0.8 (very positive)
  Summary: Handles IDEs and VMs easily, comfortable keyboard, accurate display

QUESTION: Do sentiment scores align with star ratings?

ANSWER: Generally YES, but with interesting exceptions:

STRONG ALIGNMENT (Most Cases):
- 1-star reviews: -0.8 to -0.9 sentiment (very negative)
- 5-star reviews: +0.8 to +0.9 sentiment (very positive)
- 3-star reviews: -0.2 to +0.2 sentiment (neutral/mixed)

INTERESTING MISMATCHES (Why they differ):

1. POSITIVE WORDS, NEGATIVE EXPERIENCE:
   - Sarcasm: "Great! It broke after 2 days" (positive words, negative meaning)
   - Polite complaints: "Thank you for trying" (polite but dissatisfied)
   
2. NEGATIVE WORDS, POSITIVE EXPERIENCE:
   - Constructive criticism: "Only complaint is the fan noise" (mostly positive, one negative)
   - Exceeded expectations: "I was worried about X but..." (mentions concern then praises)
   
3. MIXED REVIEWS (Most Common 3-4 Star):
   - "Great features BUT expensive" → Positive sentiment, 3 stars (price issue)
   - "Decent product with some issues" → Neutral sentiment, 3 stars
   - "Good but not great" → Slightly positive sentiment, 3 stars

4. CULTURAL DIFFERENCES:
   - Some cultures express satisfaction more reservedly
   - Some are more direct about complaints
   - Rating scales interpreted differently across cultures

5. BRIEF VS DETAILED REVIEWS:
   - "Good" (5 stars) → Low positive sentiment (not much emotion expressed)
   - Detailed enthusiastic review → High positive sentiment matching stars

BUSINESS IMPLICATIONS:
- Use BOTH rating and sentiment for complete picture
- Flag mismatches for manual review (might indicate sarcasm, nuanced feedback)
- Track sentiment trends over time, even within same rating levels
- Different products/categories may have different sentiment-rating relationships
- Combine with other signals (verified purchase, helpful votes) for best insights
*/

-- ============================================================================
-- ADDITIONAL LEARNING: PERFORMANCE COMPARISON
-- ============================================================================

/*
Let's compare the performance implications of different approaches:

APPROACH 1: Nested functions (Simple but inefficient)
---------------------------------------------------------
SNOWFLAKE.CORTEX.SENTIMENT(
  SNOWFLAKE.CORTEX.TRANSLATE(review_text, language, 'en')
)

Cost: 2 function calls per row
Clarity: Very clear - easy to understand
Best for: Small datasets, learning, prototyping

APPROACH 2: CTE pattern (Good balance)
---------------------------------------------------------
WITH translated AS (
  SELECT ..., TRANSLATE(...) AS english_text
  FROM reviews
)
SELECT ..., SENTIMENT(english_text), SUMMARIZE(english_text)
FROM translated

Cost: 1 translate + 2 other functions per row = 3 total
Clarity: Clear and maintainable
Best for: Most production use cases

APPROACH 3: CTE + LATERAL (Most efficient)
---------------------------------------------------------
WITH translated AS (
  SELECT ..., TRANSLATE(...) AS english_text FROM reviews
)
SELECT ...
FROM translated,
LATERAL (
  SELECT 
    SENTIMENT(english_text) AS s,
    SUMMARIZE(english_text) AS sum
)

Cost: 1 translate, 1 sentiment, 1 summarize = 3 total (same as approach 2)
Clarity: Slightly more complex
Best for: Large datasets, performance-critical applications
Advantage: Explicitly guarantees single calculation

RECOMMENDATION:
- Learning: Use nested functions (Approach 1)
- Production: Use CTE or CTE+LATERAL (Approaches 2-3)
- The optimized answer key shows Approach 3 so instructors can teach best practices
*/

-- ============================================================================
-- COMMON PITFALLS AND HOW TO AVOID THEM
-- ============================================================================

/*
PITFALL 1: Calling Cortex functions multiple times
❌ BAD:
SELECT 
  SENTIMENT(text) AS score,
  CASE WHEN SENTIMENT(text) > 0 THEN 'Positive' ELSE 'Negative' END AS category
FROM table;

✅ GOOD:
SELECT 
  score,
  CASE WHEN score > 0 THEN 'Positive' ELSE 'Negative' END AS category
FROM (SELECT SENTIMENT(text) AS score FROM table);


PITFALL 2: Forgetting to handle NULL values
❌ BAD:
SELECT SENTIMENT(description) FROM tickets;
-- Fails if description is NULL

✅ GOOD:
SELECT COALESCE(SENTIMENT(description), 0) AS sentiment FROM tickets;
-- or filter: WHERE description IS NOT NULL


PITFALL 3: Inefficient translation
❌ BAD:
SELECT 
  TRANSLATE(text, lang, 'en'),
  SENTIMENT(TRANSLATE(text, lang, 'en')),
  SUMMARIZE(TRANSLATE(text, lang, 'en'))
FROM reviews;

✅ GOOD:
WITH english AS (
  SELECT TRANSLATE(text, lang, 'en') AS en_text FROM reviews
)
SELECT en_text, SENTIMENT(en_text), SUMMARIZE(en_text) FROM english;


PITFALL 4: Not considering language detection
❌ BAD:
SELECT TRANSLATE(text, 'es', 'en') FROM reviews;
-- Assumes all are Spanish

✅ GOOD:
SELECT TRANSLATE(text, language_column, 'en') FROM reviews;
-- Uses stored language code


PITFALL 5: Forgetting about escaping single quotes
❌ BAD:
WHERE description LIKE '%customer's complaint%'
-- Syntax error!

✅ GOOD:
WHERE description LIKE '%customer''s complaint%'
-- Escape with double single quote
*/

-- ============================================================================
-- KEY TAKEAWAYS FOR WORKSHEET 1
-- ============================================================================

/*
FUNDAMENTAL CONCEPTS:
===================

1. SENTIMENT Function
   - Returns: -1 (very negative) to +1 (very positive)
   - Use cases: Priority routing, satisfaction tracking, alert triggers
   - Thresholds: < -0.5 (negative), -0.5 to +0.5 (neutral), > +0.5 (positive)
   - Can be used in: SELECT, WHERE, ORDER BY, CASE statements

2. TRANSLATE Function
   - Syntax: TRANSLATE(text, source_language, target_language)
   - Supports: 100+ languages with ISO codes (en, es, fr, de, ja, zh, etc.)
   - Use cases: Global support, multilingual analysis, content localization
   - Best practice: Translate once, analyze multiple times

3. SUMMARIZE Function
   - Purpose: Condenses text while preserving key information
   - Compression: Typically 15-30% of original length
   - Use cases: Quick overviews, executive summaries, email digests
   - Works on: Any text length (short to very long)

4. FUNCTION COMPOSITION
   - Functions can be nested: SENTIMENT(TRANSLATE(text, 'es', 'en'))
   - Use CTEs for efficiency: Calculate once, use multiple times
   - LATERAL joins: Advanced pattern for complex pipelines
   - Always consider: readability vs. performance trade-offs

PERFORMANCE BEST PRACTICES:
==========================
✓ Use subqueries or CTEs to avoid duplicate function calls
✓ Filter data before applying Cortex functions when possible
✓ Consider LATERAL joins for complex multi-function pipelines
✓ Test with small datasets before scaling up
✓ Monitor credit usage in production

PRODUCTION CONSIDERATIONS:
========================
✓ Handle NULL values appropriately (COALESCE, WHERE filters)
✓ Set up error handling for edge cases
✓ Validate language codes before translation
✓ Consider caching results for frequently-accessed data
✓ Monitor quality and accuracy over time
✓ Document expected behaviors and thresholds

BUSINESS VALUE:
=============
✓ Analyze customer sentiment across all languages
✓ Automatically prioritize urgent issues
✓ Generate summaries of long documents/calls
✓ Reduce manual review time by 70-90%
✓ Enable real-time insights from unstructured data
✓ Scale globally without language barriers

NO EXTERNAL DEPENDENCIES:
========================
✓ Everything runs in Snowflake - no external APIs
✓ No Python, no model deployment, no infrastructure
✓ Scales automatically with your data
✓ Pay only for what you use (per-token pricing)
✓ Enterprise security and governance included

NEXT STEPS:
==========
✓ Move to Worksheet 2 for CORTEX.COMPLETE and advanced LLM usage
✓ Learn classification, extraction, and content generation
✓ Build end-to-end AI applications entirely in SQL
✓ Combine multiple Cortex functions for sophisticated workflows
*/
