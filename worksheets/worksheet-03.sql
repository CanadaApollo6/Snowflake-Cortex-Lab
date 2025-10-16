/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - WORKSHEET 3
 * CORTEX SEARCH: Semantic Search and RAG
 *
 * Time: 15 minutes (core exercises) + 10 minutes (optional/advanced)
 * Difficulty: Intermediate to Advanced
 *
 * In this worksheet, you'll create a Cortex Search service and use it for
 * semantic search and Retrieval Augmented Generation (RAG) patterns.
 *
 * LEARNING OBJECTIVES:
 * - Understand semantic vs keyword search
 * - Create a Cortex Search service
 * - Query with natural language
 * - Combine search + LLM for RAG (Retrieval Augmented Generation)
 * - Build a knowledge base Q&A system
 *
 * STRUCTURE:
 * ⭐ CORE EXERCISES (3.1-3.5): Complete these in the workshop
 * 🎯 OPTIONAL EXERCISES (3.6): If time permits
 * 🚀 ADVANCED EXERCISES (3.7-3.9): For post-workshop practice
 *
 *******************************************************************************/

USE ROLE CORTEX_LAB_USER;
USE WAREHOUSE CORTEX_LAB_WH;
USE DATABASE LAB_DATA;

-- ============================================================================
-- 🏃 FAST TRACK: Running short on time?
-- ============================================================================
/*
  If you're running behind schedule:
  1. Complete Exercise 3.2 (create the search service) - LINE 70
  2. Wait ~60 seconds for it to become ACTIVE
  3. Skip directly to Exercise 3.6 (Final Showcase Query) - LINE 377

  This will show you the complete RAG pattern in action!
*/

-- ============================================================================
-- ⭐ CORE EXERCISES - COMPLETE THESE FIRST (15 MINUTES)
-- ============================================================================

-- ============================================================================
-- EXERCISE 3.1: TRADITIONAL vs SEMANTIC SEARCH (2 minutes)
-- See the difference between keyword matching and understanding meaning
-- ============================================================================

/*
  SCENARIO: A customer asks "How do I fix connection problems?"
  Traditional search looks for exact words. Semantic search understands meaning.
*/

-- STEP 1: Traditional keyword search (the old way)
USE SCHEMA SAMPLES;

SELECT 
  doc_id,
  title,
  doc_type,
  'Traditional Search' AS search_type
FROM PRODUCT_DOCS
WHERE LOWER(content) LIKE '%connection problems%'
   OR LOWER(content) LIKE '%connectivity issues%'
   OR LOWER(title) LIKE '%connection%';

-- Notice: You have to think of every possible way someone might phrase the question!

-- STEP 2: Now let's prepare for semantic search with Cortex Search
-- First, let's look at what we'll be searching
SELECT 
  doc_id,
  title,
  doc_type,
  LEFT(content, 200) AS content_preview,
  LENGTH(content) AS content_length
FROM PRODUCT_DOCS
ORDER BY doc_type, title;

-- ============================================================================
-- EXERCISE 3.2: CREATE A CORTEX SEARCH SERVICE (3 minutes)
-- Build a semantic search engine on your documentation
-- ============================================================================

/*
  Cortex Search creates vector embeddings of your content and enables
  semantic search - finding documents by meaning, not just keywords.
*/

-- STEP 1: Create schema for search services
USE SCHEMA CORTEX_SERVICES;

-- STEP 2: Create a Cortex Search Service on product documentation
-- Note: This may take 30-60 seconds to index the documents

CREATE OR REPLACE CORTEX SEARCH SERVICE PRODUCT_DOCS_SEARCH
ON content
ATTRIBUTES title, doc_type
WAREHOUSE = CORTEX_LAB_WH
TARGET_LAG = '1 minute'
AS (
  SELECT 
    doc_id,
    content,
    title,
    doc_type
  FROM LAB_DATA.SAMPLES.PRODUCT_DOCS
);

-- STEP 3: Check if the search service is ready
-- Run this until you see "indexing_state":"ACTIVE"
DESCRIBE CORTEX SEARCH SERVICE PRODUCT_DOCS_SEARCH;

-- Wait for the service to be ACTIVE before proceeding
-- This usually takes 30-60 seconds for this small dataset

-- ============================================================================
-- EXERCISE 3.3: SEMANTIC SEARCH QUERIES (3 minutes)
-- Ask questions in natural language
-- ============================================================================

/*
  Now we can search using natural language, and Cortex will find 
  semantically relevant documents even if they don't contain exact keywords.
*/

-- STEP 1: Search for connection issues (semantic search)
SELECT 
  doc_id,
  title,
  doc_type,
  content,
  search_score  -- Higher score = more relevant
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'How do I fix Wi-Fi connection problems?'
  )
)
ORDER BY search_score DESC
LIMIT 5;

-- Notice: It finds the SmartCam troubleshooting doc even though 
-- the query said "Wi-Fi" and the doc says "network"!

-- STEP 2: Try different natural language queries
SELECT 
  query_text,
  doc_id,
  title,
  search_score
FROM (
  SELECT 
    'battery life tips' AS query_text,
    doc_id,
    title,
    search_score
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      'How can I make my battery last longer?'
    )
  )
  
  UNION ALL
  
  SELECT 
    'headphone pairing' AS query_text,
    doc_id,
    title,
    search_score
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      'How do I connect my headphones to my phone?'
    )
  )
  
  UNION ALL
  
  SELECT 
    'product features' AS query_text,
    doc_id,
    title,
    search_score
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      'What are the main features of the smartwatch?'
    )
  )
)
ORDER BY query_text, search_score DESC;

-- STEP 3: YOUR TURN - Search for specific issues
-- TODO: Write searches for these customer questions:
--   1. "My device won't turn on"
--   2. "How to charge the power bank"
--   3. "Product specifications"

SELECT 
  doc_id,
  title,
  doc_type,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    -- TODO: Replace with your search query
    'My device won''t turn on'
  )
)
ORDER BY search_score DESC
LIMIT 5;

-- ============================================================================
-- EXERCISE 3.4: RETRIEVAL AUGMENTED GENERATION (RAG) (4 minutes)
-- Combine search + LLM for accurate, grounded answers
-- ============================================================================

/*
  RAG Pattern (The most important pattern in this workshop!):
  1. Search for relevant documents (RETRIEVAL)
  2. Pass them to an LLM as context (AUGMENTATION)
  3. LLM generates answer based on actual docs (GENERATION)

  This prevents hallucination - the LLM only uses real information!
*/

-- STEP 1: Simple RAG - answer a question using documentation
WITH search_results AS (
  SELECT content
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      'How do I pair the headphones?'
    )
  )
  LIMIT 3  -- Use top 3 most relevant docs
)
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',
  'Answer this question using ONLY the information provided below. 
  If the answer is not in the provided context, say "I don''t have that information."
  
  Question: How do I pair the UltraSound Pro headphones with my device?
  
  Context from documentation:
  ' || LISTAGG(content, '\n\n---\n\n') WITHIN GROUP (ORDER BY content) || '
  
  Answer:'
) AS ai_answer
FROM search_results;

-- STEP 2: YOUR TURN - Try the RAG pattern with a different question
-- TODO: Change the search question below to ask about battery life, charging, or setup
WITH search_results AS (
  SELECT content
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      -- TODO: Try different questions like:
      -- 'How long does battery last?'
      -- 'How do I charge my device?'
      -- 'What should I do if it won''t turn on?'
      'How do I pair Bluetooth headphones?'
    )
  )
  LIMIT 3
)
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',
  'Answer this question using ONLY the documentation provided. Keep it concise.

  Question: How do I pair Bluetooth headphones?

  Documentation:
  ' || LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY content) || '

  Answer:'
) AS ai_answer
FROM search_results;

-- ⏱️ TIME CHECK: You should be at ~12 minutes elapsed. Great progress!

-- ============================================================================
-- EXERCISE 3.5: SUPPORT TICKET AUTO-RESPONSE (3 minutes)
-- Use search + LLM to generate responses to support tickets
-- ============================================================================

/*
  SCENARIO: When a support ticket arrives, automatically:
  1. Search for relevant documentation
  2. Generate a helpful response
  3. Include relevant documentation links
*/

-- STEP 1: Auto-respond to a support ticket using RAG
WITH ticket AS (
  SELECT 
    ticket_id,
    subject,
    description,
    -- Translate to English if needed
    CASE 
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END AS english_description
  FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
  WHERE ticket_id = 'TKT-006'  -- French ticket about defective laptop
),
relevant_help AS (
  SELECT 
    doc_id,
    title,
    content,
    search_score
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
  t.description AS original_ticket,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'You are a customer support agent. Write a helpful, empathetic response to this customer ticket.
    Use the provided documentation to give specific troubleshooting steps.
    Keep the response under 150 words.
    
    Customer Issue: ' || t.english_description || '
    
    Relevant Documentation:
    ' || (SELECT LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY search_score DESC) FROM relevant_help) || '
    
    Support Response:'
  ) AS suggested_response,
  (SELECT LISTAGG(title, ', ') WITHIN GROUP (ORDER BY search_score DESC) FROM relevant_help) AS documentation_used
FROM ticket t;

-- STEP 2: YOUR TURN - Try with a different ticket
-- TODO: Change the ticket_id below to try different support scenarios
-- Try: TKT-008 (German), TKT-004 (Spanish), TKT-011 (English)
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
  WHERE ticket_id = 'TKT-008'  -- TODO: Try different ticket IDs
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

-- ✅ CORE EXERCISES COMPLETE! You've learned semantic search and RAG patterns.
-- ⏱️ TIME CHECK: ~15 minutes. Ready to see it all come together!

-- ============================================================================
-- 🎯 OPTIONAL EXERCISES - IF TIME PERMITS (5-10 MINUTES)
-- ============================================================================

-- ============================================================================
-- EXERCISE 3.6: FINAL SHOWCASE QUERY
-- See the full power of Cortex in one query!
-- ============================================================================

/*
  This query demonstrates everything you've learned:
  - Multi-language support (TRANSLATE)
  - Sentiment analysis
  - Semantic search (CORTEX SEARCH)
  - RAG pattern (Search + LLM)
  - All in pure SQL!
*/

WITH customer_inquiries AS (
  -- Simulating incoming customer questions
  SELECT 'How do I pair my headphones?' AS question, 'en' AS lang
  UNION ALL SELECT '¿Cuál es la garantía?', 'es'
  UNION ALL SELECT 'La caméra ne fonctionne pas', 'fr'
  UNION ALL SELECT 'Battery draining too fast', 'en'
),
processed_inquiries AS (
  SELECT
    question AS original_question,
    lang,
    -- Translate to English if needed
    CASE
      WHEN lang = 'en' THEN question
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(question, lang, 'en')
    END AS english_question,
    -- Get sentiment
    SNOWFLAKE.CORTEX.SENTIMENT(question) AS sentiment,
    -- Search for relevant docs
    (
      SELECT LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY search_score DESC)
      FROM TABLE(
        LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
          CASE
            WHEN lang = 'en' THEN question
            ELSE SNOWFLAKE.CORTEX.TRANSLATE(question, lang, 'en')
          END
        )
      )
      LIMIT 2
    ) AS relevant_docs
  FROM customer_inquiries
)
SELECT
  original_question,
  lang AS original_language,
  english_question,
  ROUND(sentiment, 2) AS sentiment_score,
  -- Generate answer using RAG
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Answer this customer question using the provided documentation. Be helpful and specific.

    Question: ' || english_question || '

    Documentation:
    ' || relevant_docs || '

    Answer:'
  ) AS generated_answer
FROM processed_inquiries;

-- 🎉 FANTASTIC! You've seen how Cortex brings AI directly into your SQL queries!

-- ============================================================================
-- 🚀 ADVANCED EXERCISES - FOR POST-WORKSHOP PRACTICE
-- These exercises are for after the workshop or for fast learners
-- ============================================================================

-- ============================================================================
-- EXERCISE 3.7: FILTER SEARCH BY ATTRIBUTES
-- Narrow searches to specific product categories or document types
-- ============================================================================

/*
  You can filter search results by the attributes you defined when 
  creating the search service (title, doc_type in our case)
*/

-- STEP 1: Search only troubleshooting guides
SELECT 
  doc_id,
  title,
  doc_type,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'device not working',
    {'filter': {'@eq': {'doc_type': 'troubleshooting'}}}
  )
)
ORDER BY search_score DESC;

-- STEP 2: Search only user manuals
SELECT 
  doc_id,
  title,
  doc_type,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'setup instructions',
    {'filter': {'@eq': {'doc_type': 'user_manual'}}}
  )
)
ORDER BY search_score DESC;

-- STEP 3: YOUR TURN - Product-specific documentation search
-- TODO: Search for battery information only in user manuals
SELECT 
  doc_id,
  title,
  doc_type,
  LEFT(content, 300) AS content_preview,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    -- TODO: Your search query here
    'battery charging optimization',
    {'filter': {'@eq': {'doc_type': 'user_manual'}}}
  )
)
ORDER BY search_score DESC
LIMIT 5;

-- ============================================================================
-- EXERCISE 3.8: BUILD A COMPLETE KNOWLEDGE BASE CHATBOT (ADVANCED)
-- Putting it all together with reusable functions!
-- ============================================================================

/*
  FINAL CHALLENGE: Build a complete chatbot system that:
  1. Takes a customer question
  2. Searches relevant documentation
  3. Generates an accurate, helpful answer
  4. Cites sources
  5. Handles edge cases
*/

-- Create a reusable chatbot query pattern
CREATE OR REPLACE FUNCTION ASK_PRODUCT_CHATBOT(question STRING)
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

-- STEP 1: Test the chatbot function
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT(
  'How do I enable noise cancellation on the headphones?'
));

-- STEP 2: Test with multiple questions
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT('What is the battery life of the smart watch?'))
UNION ALL
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT('Can the camera work without WiFi?'))
UNION ALL
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT('How do I update my laptop firmware?'))
UNION ALL
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT('What is your return policy?'));

-- STEP 3: YOUR TURN - Test the chatbot with your own questions
-- TODO: Ask 3 questions you think customers might ask
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT(
  -- TODO: Your question here
  'Which products are waterproof?'
));

-- ============================================================================
-- EXERCISE 3.9: MULTI-LINGUAL CHATBOT (ADVANCED)
-- Handle questions in any language
-- ============================================================================

/*
  ADVANCED: Combine translation + search + RAG for global support
*/

CREATE OR REPLACE FUNCTION ASK_PRODUCT_CHATBOT_MULTILINGUAL(
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

-- Test multilingual chatbot
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  '¿Cuánto tiempo dura la batería de los auriculares?',  -- Spanish
  'es'
));

SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  'Comment puis-je réinitialiser ma caméra?',  -- French
  'fr'
));

-- ============================================================================
-- EXERCISE 3.10: CREATE YOUR OWN SEARCH SERVICE (BONUS)
-- Practice creating a search service on different data
-- ============================================================================

/*
  CHALLENGE: Create a search service on customer reviews
  This will let you search reviews semantically
*/

-- TODO: Create a Cortex Search Service on PRODUCT_REVIEWS
-- Hint: Search on review_text, with attributes for product_name and rating

CREATE OR REPLACE CORTEX SEARCH SERVICE PRODUCT_REVIEWS_SEARCH
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

-- Wait for it to be active, then test it
DESCRIBE CORTEX SEARCH SERVICE PRODUCT_REVIEWS_SEARCH;

-- TODO: Search for reviews mentioning specific features
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

-- TODO: Use RAG to summarize what customers say about a feature
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

/*******************************************************************************
 * WORKSHEET 3 COMPLETE! ✓
 *
 * 🎉 CONGRATULATIONS! YOU'VE COMPLETED THE SNOWFLAKE CORTEX AI LAB! 🎉
 *
 * KEY TAKEAWAYS:
 * ✓ Semantic search finds documents by meaning, not just keywords
 * ✓ Cortex Search Service makes semantic search easy with SQL
 * ✓ RAG (Retrieval Augmented Generation) prevents LLM hallucination
 * ✓ Search + LLM = powerful, accurate knowledge base systems
 *
 * WHAT YOU'VE MASTERED ACROSS ALL 3 WORKSHEETS:
 * ✓ SENTIMENT - Analyze emotions in text
 * ✓ TRANSLATE - Break down language barriers
 * ✓ SUMMARIZE - Condense information
 * ✓ COMPLETE - Full LLM capabilities for classification, extraction, generation
 * ✓ CORTEX SEARCH - Semantic search on unstructured data
 * ✓ RAG Patterns - Build accurate, grounded AI applications
 *
 * 💡 THE BIG IDEA:
 * You can now build sophisticated AI applications using ONLY SQL - no Python,
 * no external APIs, no complex infrastructure. Your data and AI models are
 * unified in Snowflake!
 *
 * NEXT STEPS:
 * 1. 🏠 Try this in your own Snowflake trial account (signup.snowflake.com)
 * 2. 📊 Explore Cortex Analyst for natural language to SQL queries
 * 3. 🚀 Build your own AI applications with your company's data
 * 4. 📚 Visit docs.snowflake.com/cortex for advanced features
 * 5. 🧪 Experiment with the advanced exercises (3.7-3.10) above
 *
 * REAL-WORLD USE CASES YOU CAN NOW BUILD:
 * • Automated customer support triage and response generation
 * • Multi-language product review analysis and sentiment tracking
 * • Intelligent document search and question-answering systems
 * • Sales call analysis and action item extraction
 * • Content moderation and classification at scale
 *
 * Thank you for participating in the Snowflake Cortex AI Lab! 🙏
 *
 *******************************************************************************/