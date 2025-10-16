/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - WORKSHEET 3 ANSWER KEY
 * CORTEX SEARCH: Semantic Search and RAG
 *
 * This file contains complete solutions for all TODO exercises in Worksheet 3.
 * Use this to verify your answers or for instructor reference.
 *
 * IMPORTANT NOTE:
 * - Search scores may vary slightly between runs
 * - LLM outputs are non-deterministic (different wording is normal)
 * - Search service must be ACTIVE before exercises will work
 *
 *******************************************************************************/

USE ROLE CORTEX_LAB_USER;
USE WAREHOUSE CORTEX_LAB_WH;
USE DATABASE LAB_DATA;

-- ============================================================================
-- EXERCISE 3.3: SEMANTIC SEARCH QUERIES
-- ============================================================================

-- STEP 3: YOUR TURN - Search for specific issues
-- Three example searches requested:

-- SEARCH 1: "My device won't turn on"
-- ANSWER:
SELECT
  doc_id,
  title,
  doc_type,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'My device won''t turn on'
  )
)
ORDER BY search_score DESC
LIMIT 5;

/*
EXPECTED RESULTS:
Should return troubleshooting docs about:
- PowerBook Elite first time setup (DOC-003) - mentions power button
- SmartCam troubleshooting (DOC-002) - charging/power issues
- FitTrack features (DOC-004) - power management

KEY INSIGHT:
Even though we searched "won't turn on", it finds docs about:
- "Press the power button"
- "Charging issues"
- "Battery problems"
The semantic search understands these are related concepts!
*/

-- SEARCH 2: "How to charge the power bank"
-- ANSWER:
SELECT
  doc_id,
  title,
  doc_type,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'How to charge the power bank'
  )
)
ORDER BY search_score DESC
LIMIT 5;

/*
EXPECTED RESULTS:
Should return:
- DOC-005: QuickCharge Power Bank FAQ (highest score)
  Contains detailed charging information
- Possibly DOC-001, DOC-004: Other devices with charging info

KEY INSIGHT:
Finds the QuickCharge docs even though our query said "power bank"
and the doc title says "QuickCharge". Semantic search understands
these refer to the same type of device!
*/

-- SEARCH 3: "Product specifications"
-- ANSWER:
SELECT
  doc_id,
  title,
  doc_type,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'Product specifications'
  )
)
ORDER BY search_score DESC
LIMIT 5;

/*
EXPECTED RESULTS:
Should return docs containing specs like:
- Battery life specifications
- Hardware specifications (processor, RAM, storage)
- Physical dimensions
- Technical capabilities

KEY INSIGHT:
Finds docs with specifications even if they don't use the word
"specifications" - might say "features" or just list the specs.
*/

-- ============================================================================
-- EXERCISE 3.4: RAG PATTERN
-- ============================================================================

-- STEP 2: YOUR TURN - Try the RAG pattern with a different question
-- ANSWER (with multiple example questions):

-- EXAMPLE 1: Battery life question
WITH search_results AS (
  SELECT content
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      'How long does battery last?'
    )
  )
  LIMIT 3
)
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',
  'Answer this question using ONLY the documentation provided. Keep it concise.

  Question: How long does the battery last?

  Documentation:
  ' || LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY content) || '

  Answer:'
) AS ai_answer
FROM search_results;

/*
EXPECTED ANSWER (example - wording will vary):
"Battery life varies by product:
- UltraSound Pro Headphones: Up to 30 hours playback, 24-26 hours with ANC on
- FitTrack Smart Watch: 5-7 days typical use, 3-4 days heavy use, up to 10 days in battery saver mode
- QuickCharge Power Bank: Can charge phones 3-4 times depending on phone battery size"

KEY INSIGHT:
The LLM found information about MULTIPLE products because our search
returned docs for all of them. The answer is grounded in real documentation!
*/

-- EXAMPLE 2: Charging question
WITH search_results AS (
  SELECT content
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      'How do I charge my device?'
    )
  )
  LIMIT 3
)
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',
  'Answer this question using ONLY the documentation provided. Keep it concise.

  Question: How do I charge my device?

  Documentation:
  ' || LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY content) || '

  Answer:'
) AS ai_answer
FROM search_results;

/*
EXPECTED ANSWER (example):
"Charging instructions vary by device:
- Headphones: Connect USB-C cable to charging port on right earcup. LED turns red while charging, green when full. Takes 2 hours for full charge.
- Smart Watch: Use magnetic charging cable. Takes 2 hours for full charge.
- Power Bank: Use 18W USB-C charger, takes 6-7 hours. LED indicators show charging progress (each LED = 25%)."
*/

-- EXAMPLE 3: Troubleshooting question
WITH search_results AS (
  SELECT content
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      'What should I do if it won''t turn on?'
    )
  )
  LIMIT 3
)
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',
  'Answer this question using ONLY the documentation provided. Keep it concise.

  Question: What should I do if my device won't turn on?

  Documentation:
  ' || LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY content) || '

  Answer:'
) AS ai_answer
FROM search_results;

/*
EXPECTED ANSWER (example):
"Troubleshooting steps:
1. Ensure device is charged - connect to power and check LED indicators
2. Try different power outlet or charging cable
3. Press and hold power button for 3-5 seconds
4. For cameras, check if battery needs charging or if entered sleep mode
5. If still not working, device may be defective - contact support for replacement"

KEY INSIGHT:
Notice the answer synthesizes information from multiple documents
and presents it as coherent troubleshooting steps. This is the power of RAG!
*/

-- ============================================================================
-- EXERCISE 3.5: SUPPORT TICKET AUTO-RESPONSE
-- ============================================================================

-- STEP 2: YOUR TURN - Try with a different ticket
-- ANSWER with multiple examples:

-- EXAMPLE 1: German ticket (TKT-008)
WITH ticket AS (
  SELECT
    ticket_id,
    subject,
    description,
    CASE
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END AS english_description
  FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
  WHERE ticket_id = 'TKT-008'
),
relevant_help AS (
  SELECT
    content
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      (SELECT english_description FROM ticket)
    )
  )
  LIMIT 2
)
SELECT
  t.ticket_id,
  t.subject,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Write a helpful support response to this customer. Use the documentation for specific steps.
    Keep it under 100 words.

    Customer Issue: ' || t.english_description || '

    Documentation:
    ' || (SELECT LISTAGG(content, '\n---\n') FROM relevant_help) || '

    Support Response:'
  ) AS suggested_response
FROM ticket t;

/*
TICKET TKT-008 (German): Wrong item received - ordered camera, got headphones

EXPECTED RESPONSE (example):
"I sincerely apologize for sending you the wrong item. This is not the experience
we want our customers to have. I'll immediately process a shipment for the correct
camera you ordered, with expedited shipping at no extra charge so you have it for
your weekend event. You can keep the headphones as our apology, or we'll provide
a prepaid return label if you prefer. Your replacement camera will ship within
24 hours. I'll send you the tracking number as soon as it's available."

KEY INSIGHT:
The response acknowledges the urgency mentioned in the ticket (weekend event)
and offers appropriate compensation. The LLM understood context!
*/

-- EXAMPLE 2: Spanish ticket (TKT-004)
WITH ticket AS (
  SELECT
    ticket_id,
    subject,
    description,
    CASE
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END AS english_description
  FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
  WHERE ticket_id = 'TKT-004'
),
relevant_help AS (
  SELECT
    content
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      (SELECT english_description FROM ticket)
    )
  )
  LIMIT 2
)
SELECT
  t.ticket_id,
  t.subject,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Write a helpful support response to this customer. Use the documentation for specific steps.
    Keep it under 100 words.

    Customer Issue: ' || t.english_description || '

    Documentation:
    ' || (SELECT LISTAGG(content, '\n---\n') FROM relevant_help) || '

    Support Response:'
  ) AS suggested_response
FROM ticket t;

/*
TICKET TKT-004 (Spanish): Payment declined multiple times

EXPECTED RESPONSE (example):
"I understand how frustrating payment issues can be, especially when you need
items urgently for a gift. Since your bank confirms the card is fine, this may
be a temporary system issue. Please try these steps: 1) Clear your browser
cache and cookies, 2) Try a different browser or device, 3) If still failing,
I can process your order over the phone. Please call us at [number] and
reference ticket TKT-004. We'll ensure your gift order is completed today."
*/

-- EXAMPLE 3: English ticket (TKT-011)
WITH ticket AS (
  SELECT
    ticket_id,
    subject,
    description,
    CASE
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END AS english_description
  FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
  WHERE ticket_id = 'TKT-011'
),
relevant_help AS (
  SELECT
    content
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      (SELECT english_description FROM ticket)
    )
  )
  LIMIT 2
)
SELECT
  t.ticket_id,
  t.subject,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Write a helpful support response to this customer. Use the documentation for specific steps.
    Keep it under 100 words.

    Customer Issue: ' || t.english_description || '

    Documentation:
    ' || (SELECT LISTAGG(content, '\n---\n') FROM relevant_help) || '

    Support Response:'
  ) AS suggested_response
FROM ticket t;

/*
TICKET TKT-011 (English): Need to change shipping address

EXPECTED RESPONSE (example):
"No problem! I can update your shipping address since the order was just placed
10 minutes ago. I've immediately updated order ORD-98765 to ship to your new
address. The order hasn't entered our fulfillment system yet, so we caught it
in time. You'll receive a confirmation email within 5 minutes showing the updated
address. Your order will ship on schedule with no delays. Thank you for catching
this so quickly!"
*/

-- ============================================================================
-- EXERCISE 3.7: FILTER SEARCH BY ATTRIBUTES
-- ============================================================================

-- STEP 3: YOUR TURN - Product-specific documentation search
-- ANSWER:
SELECT
  doc_id,
  title,
  doc_type,
  LEFT(content, 300) AS content_preview,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'battery charging optimization',
    {'filter': {'@eq': {'doc_type': 'user_manual'}}}
  )
)
ORDER BY search_score DESC
LIMIT 5;

/*
EXPLANATION:
- Search query: 'battery charging optimization'
- Filter: Only user_manual doc_type
- This narrows results to setup/usage docs (not troubleshooting or FAQs)

EXPECTED RESULTS:
Should return user manuals that mention:
- Battery optimization settings
- Charging best practices
- Power management tips

From documents like:
- DOC-001: UltraSound Pro (charging instructions)
- DOC-003: PowerBook Elite (battery optimization tips)
- DOC-004: FitTrack (battery life management)

KEY INSIGHT:
Filtering by attributes lets you narrow semantic search to specific
categories. Useful when you know what TYPE of doc you need.
*/

-- ALTERNATIVE: Search only troubleshooting docs for specific product
SELECT
  doc_id,
  title,
  doc_type,
  LEFT(content, 300) AS content_preview,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'connection problems',
    {'filter': {'@eq': {'doc_type': 'troubleshooting'}}}
  )
)
ORDER BY search_score DESC
LIMIT 5;

/*
This would return only troubleshooting guides about connectivity,
filtering out user manuals and FAQs.
*/

-- ============================================================================
-- EXERCISE 3.8: BUILD COMPLETE CHATBOT (ADVANCED)
-- ============================================================================

-- The worksheet creates a UDF. Here's the complete working solution:

CREATE OR REPLACE FUNCTION LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT(question STRING)
RETURNS TABLE (
  question STRING,
  answer STRING,
  confidence STRING,
  sources STRING
)
AS
$$
  WITH search_results AS (
    SELECT
      doc_id,
      title,
      content,
      search_score
    FROM TABLE(
      LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(question)
    )
    LIMIT 3
  ),
  generated_answer AS (
    SELECT
      question,
      SNOWFLAKE.CORTEX.COMPLETE(
        'mixtral-8x7b',
        'You are a knowledgeable product support assistant. Answer this question using ONLY the provided documentation.
        Be specific, mention product names and features when relevant.
        If the documentation does not contain the answer, say: "I don''t have specific documentation on that topic. Please contact our support team for assistance."
        Keep your answer concise and helpful.

        Question: ' || question || '

        Documentation:
        ' || (SELECT LISTAGG(title || ':\n' || content, '\n\n---\n\n') WITHIN GROUP (ORDER BY search_score DESC) FROM search_results) || '

        Answer:'
      ) AS answer,
      CASE
        WHEN (SELECT MAX(search_score) FROM search_results) > 0.8 THEN 'High'
        WHEN (SELECT MAX(search_score) FROM search_results) > 0.5 THEN 'Medium'
        ELSE 'Low'
      END AS confidence,
      (SELECT LISTAGG(title, '; ') WITHIN GROUP (ORDER BY search_score DESC) FROM search_results) AS sources
  )
  SELECT * FROM generated_answer
$$;

-- STEP 3: Test with your own questions
-- ANSWER EXAMPLES:

-- Example 1: Waterproof question
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT(
  'Which products are waterproof?'
));

/*
EXPECTED ANSWER (example):
Question: Which products are waterproof?
Answer: "The FitTrack Smart Watch is water-resistant with a 5ATM rating,
making it suitable for swimming in pools and shallow water. However, it is
not suitable for scuba diving or high-pressure water activities. The other
products in our catalog (UltraSound Pro Headphones, PowerBook Elite Laptop,
SmartCam 4K, QuickCharge Power Bank) are not waterproof."
Confidence: High
Sources: FitTrack Smart Watch - Features Overview
*/

-- Example 2: Warranty question
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT(
  'What is your warranty policy?'
));

/*
EXPECTED ANSWER (example):
Question: What is your warranty policy?
Answer: "All products include a 1-year manufacturer warranty covering
manufacturing defects, material defects, and workmanship issues. The warranty
does not cover physical damage from drops, water damage (except within product
specs), normal wear and tear, or unauthorized repairs. We offer extended warranty
options at purchase: 2-year and 3-year extensions, plus accidental damage
protection. Warranty is honored worldwide."
Confidence: High
Sources: Return and Warranty Policy
*/

-- Example 3: Specific product feature
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT(
  'How do I enable noise cancellation on my headphones?'
));

/*
EXPECTED ANSWER (example):
Question: How do I enable noise cancellation on my headphones?
Answer: "To enable Active Noise Cancellation (ANC) on the UltraSound Pro
Headphones, press the ANC button once. The headphones have three modes:
press once for noise cancellation mode (blocks ambient noise), press again
for transparency mode (lets you hear surroundings), and press a third time
to turn ANC off. For best performance, ensure the earcups form a proper seal
around your ears."
Confidence: High
Sources: UltraSound Pro - Noise Cancellation
*/

-- ============================================================================
-- EXERCISE 3.9: MULTI-LINGUAL CHATBOT (ADVANCED)
-- ============================================================================

-- Complete working solution for multi-lingual UDF:

CREATE OR REPLACE FUNCTION LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  question STRING,
  question_language STRING
)
RETURNS TABLE (
  original_question STRING,
  english_question STRING,
  answer STRING,
  sources STRING
)
AS
$$
  WITH translated_question AS (
    SELECT
      question AS original_question,
      CASE
        WHEN question_language = 'en' THEN question
        ELSE SNOWFLAKE.CORTEX.TRANSLATE(question, question_language, 'en')
      END AS english_question
  ),
  search_results AS (
    SELECT
      content,
      title,
      search_score
    FROM TABLE(
      LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
        (SELECT english_question FROM translated_question)
      )
    )
    LIMIT 3
  ),
  english_answer AS (
    SELECT
      tq.original_question,
      tq.english_question,
      SNOWFLAKE.CORTEX.COMPLETE(
        'mixtral-8x7b',
        'Answer this question using the provided documentation. Be helpful and specific.

        Question: ' || tq.english_question || '

        Documentation:
        ' || (SELECT LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY search_score DESC) FROM search_results) || '

        Answer:'
      ) AS answer,
      (SELECT LISTAGG(title, ', ') WITHIN GROUP (ORDER BY search_score DESC) FROM search_results) AS sources
    FROM translated_question tq
  )
  SELECT
    original_question,
    english_question,
    CASE
      WHEN question_language = 'en' THEN answer
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(answer, 'en', question_language)
    END AS answer,
    sources
  FROM english_answer
$$;

-- Test examples:

-- Spanish question
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  '¿Cuánto tiempo dura la batería de los auriculares?',
  'es'
));

/*
EXPECTED RESULT:
Original Question: ¿Cuánto tiempo dura la batería de los auriculares?
English Question: How long does the headphone battery last?
Answer: "Los auriculares UltraSound Pro proporcionan hasta 30 horas de
reproducción con una carga completa, o 24-26 horas con la cancelación
activa de ruido activada."
Sources: UltraSound Pro - Getting Started
*/

-- French question
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  'Comment puis-je réinitialiser ma caméra?',
  'fr'
));

/*
EXPECTED RESULT:
Original Question: Comment puis-je réinitialiser ma caméra?
English Question: How do I reset my camera?
Answer: "Pour réinitialiser la SmartCam 4K, vous devez redémarrer la
caméra et votre routeur. Si les problèmes de connexion persistent, essayez
de rapprocher la caméra du routeur pendant la configuration et vérifiez
que vous utilisez un réseau 2,4 GHz."
Sources: SmartCam 4K - Common Issues
*/

-- ============================================================================
-- EXERCISE 3.10: CREATE YOUR OWN SEARCH SERVICE (BONUS)
-- ============================================================================

-- Complete solution for creating search service on reviews:

CREATE OR REPLACE CORTEX SEARCH SERVICE LAB_DATA.CORTEX_SERVICES.PRODUCT_REVIEWS_SEARCH
ON review_text
ATTRIBUTES product_name, rating
WAREHOUSE = CORTEX_LAB_WH
TARGET_LAG = '1 minute'
AS (
  SELECT
    review_id,
    review_text,
    product_name,
    rating
  FROM LAB_DATA.SAMPLES.PRODUCT_REVIEWS
);

-- Wait for it to be ACTIVE
DESCRIBE CORTEX SEARCH SERVICE LAB_DATA.CORTEX_SERVICES.PRODUCT_REVIEWS_SEARCH;

-- Search for reviews mentioning specific features
SELECT
  review_id,
  product_name,
  rating,
  review_text,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_REVIEWS_SEARCH!SEARCH(
    'sound quality and noise cancellation'
  )
)
ORDER BY search_score DESC
LIMIT 5;

/*
EXPECTED RESULTS:
Should return headphone reviews that mention:
- Sound quality
- Noise cancellation
- Audio performance
- Clear sound / crisp sound

Even if they use different wording like "audio is amazing" or
"blocks out noise perfectly"
*/

-- RAG to summarize what customers say about a feature
WITH review_search AS (
  SELECT
    review_text,
    product_name,
    rating
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_REVIEWS_SEARCH!SEARCH(
      'battery life'
    )
  )
  LIMIT 10
)
SELECT
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Based on these customer reviews, summarize what customers are saying about battery life.
    Include both positive and negative feedback.

    Reviews:
    ' || LISTAGG(product_name || ' (' || rating || ' stars): ' || review_text, '\n\n') WITHIN GROUP (ORDER BY rating DESC) || '

    Summary of battery life feedback:'
  ) AS battery_life_summary
FROM review_search;

/*
EXPECTED SUMMARY (example):
"Customer feedback on battery life is mixed. Positive reviews highlight
that the UltraSound Pro Headphones last for days on a single charge and
provide excellent battery performance. The FitTrack Smart Watch receives
praise for 5-7 day battery life. However, negative reviews note that the
FitTrack's battery life is shorter than advertised and the watch needs
frequent charging. Some customers feel battery performance doesn't meet
marketing claims for certain products."

KEY INSIGHT:
The LLM synthesizes multiple reviews to give balanced feedback,
noting both positive and negative aspects. This is incredibly useful
for product managers!
*/

-- ============================================================================
-- KEY TAKEAWAYS FOR WORKSHEET 3
-- ============================================================================

/*
1. SEMANTIC SEARCH vs KEYWORD SEARCH:
   - Keyword: Exact word matching (brittle)
   - Semantic: Meaning-based matching (flexible)
   - Cortex Search uses vector embeddings for semantic search

2. CORTEX SEARCH SERVICE:
   - Created with: CREATE CORTEX SEARCH SERVICE
   - Specify: what to search (ON column), what to filter (ATTRIBUTES)
   - Takes 30-60 seconds to index
   - Query with: TABLE(service_name!SEARCH('query'))

3. RAG PATTERN (Most Important!):
   - Problem: LLMs hallucinate (make things up)
   - Solution: Give LLM ONLY real docs to reference
   - Steps: SEARCH → pass results to LLM → LLM answers from docs
   - Result: Accurate, grounded responses

4. SEARCH FILTERING:
   - Use ATTRIBUTES to enable filtering
   - Filter syntax: {'filter': {'@eq': {'attribute': 'value'}}}
   - Useful for narrowing to specific doc types or categories

5. PRODUCTION PATTERNS:
   - Create UDFs for reusable chatbot functions
   - Add confidence scoring based on search scores
   - Track sources for transparency
   - Handle multi-language with TRANSLATE
   - Combine with SENTIMENT for prioritization

6. REAL-WORLD APPLICATIONS:
   - Customer support chatbots (search docs + answer questions)
   - Employee knowledge bases (search policies/procedures)
   - Product Q&A systems (search manuals + generate answers)
   - Code documentation search (search repos + explain code)
   - Legal document analysis (search cases + summarize findings)

7. COST & PERFORMANCE:
   - Search service: Small one-time indexing cost
   - Queries: Very fast (milliseconds)
   - LLM calls: Per-token cost
   - Optimize by: limiting search results, caching common queries

CONGRATULATIONS! You've completed all three worksheets and learned:
✓ Basic Cortex functions (SENTIMENT, TRANSLATE, SUMMARIZE)
✓ Advanced LLM usage (COMPLETE)
✓ Semantic search (CORTEX SEARCH)
✓ RAG patterns for accurate AI
✓ Building production-ready applications

You can now build sophisticated AI applications using only SQL!
*/
