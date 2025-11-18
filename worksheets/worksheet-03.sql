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
 * ⭐ CORE EXERCISES (3.1-3.5): Complete these in the workshop (15 min)
 * 🎯 OPTIONAL EXERCISES (3.6): If time permits (5 min)
 * 🚀 ADVANCED EXERCISES (3.7-3.10): For post-workshop practice (varies)
 *
 * ESTIMATED TIME PER EXERCISE:
 * - Exercise 3.1: 2 minutes (demo)
 * - Exercise 3.2: 3 minutes (create search service + wait)
 * - Exercise 3.3: 3 minutes (semantic search)
 * - Exercise 3.4: 4 minutes (RAG pattern)
 * - Exercise 3.5: 3 minutes (support automation)
 * - Exercise 3.6: 5 minutes (optional showcase)
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
  1. Complete Exercise 3.2 (create the search service) - LINE ~95
  2. Wait ~60 seconds for it to become ACTIVE
  3. Skip directly to Exercise 3.6 (Final Showcase Query) - LINE ~415

  This will show you the complete RAG pattern in action!
*/

-- ============================================================================
-- ⭐ CORE EXERCISES - COMPLETE THESE FIRST (15 MINUTES)
-- ============================================================================

-- ============================================================================
-- EXERCISE 3.1: TRADITIONAL vs SEMANTIC SEARCH (2 minutes - DEMO)
-- See the difference between keyword matching and understanding meaning
-- ============================================================================

/*
  SCENARIO: A customer asks "How do I fix connection problems?"
  Traditional search looks for exact words. Semantic search understands meaning.
  
  KEY CONCEPT: Semantic search uses vector embeddings to understand meaning,
  not just match keywords. This is why it can find "network issues" when you
  search for "connection problems" - they mean the same thing!
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
   OR LOWER(content) LIKE '%connection%';

-- Notice: You have to think of every possible way someone might phrase the question!
-- What if they say "Wi-Fi not working" or "network down" or "can't connect"?

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

-- QUESTION: How many documents do we have? How many document types?

-- ============================================================================
-- EXERCISE 3.2: CREATE A CORTEX SEARCH SERVICE (3 minutes)
-- Build a semantic search engine on your documentation
-- ============================================================================

/*
  Cortex Search creates vector embeddings of your content and enables
  semantic search - finding documents by meaning, not just keywords.
  
  CORTEX SEARCH SERVICE COMPONENTS:
  - ON clause: The text column to search (creates embeddings)
  - ATTRIBUTES: Metadata fields for filtering and display
  - WAREHOUSE: Compute for indexing and queries
  - TARGET_LAG: How fresh the index should be
  - AS: The source query defining what to index
  
  INDEXING TIME: Typically 30-60 seconds for small datasets like ours.
  Larger datasets (millions of rows) can take minutes to hours.
*/

-- STEP 1: Create schema for search services (if not exists)
USE SCHEMA CORTEX_SERVICES;

-- STEP 2: Create a Cortex Search Service on product documentation
-- Note: This may take 30-60 seconds to index the documents
-- Run this entire CREATE statement at once

CREATE OR REPLACE CORTEX SEARCH SERVICE PRODUCT_DOCS_SEARCH
ON content                    -- What to search (the text column)
ATTRIBUTES title, doc_type    -- Additional fields for filtering/display
WAREHOUSE = CORTEX_LAB_WH    -- Compute for indexing
TARGET_LAG = '1 minute'      -- How fresh the index should be
AS (
  SELECT 
    doc_id,
    content,     -- This will be converted to vector embeddings
    title,
    doc_type
  FROM LAB_DATA.SAMPLES.PRODUCT_DOCS
);

-- STEP 3: Check if the search service is ready
-- Run this query repeatedly until you see "ACTIVE" status
-- This usually takes 30-60 seconds for this small dataset

DESCRIBE CORTEX SEARCH SERVICE PRODUCT_DOCS_SEARCH;

-- ⏳ WAIT for status to show "ACTIVE" before proceeding
-- You should see output showing:
-- - name: PRODUCT_DOCS_SEARCH
-- - search_column: CONTENT
-- - state: ACTIVE (when ready)

-- While waiting, read about the RAG pattern in Exercise 3.4!

-- ============================================================================
-- EXERCISE 3.3: SEMANTIC SEARCH QUERIES (3 minutes)
-- Ask questions in natural language
-- ============================================================================

/*
  Now we can search using natural language, and Cortex will find 
  semantically relevant documents even if they don't contain exact keywords.
  
  SEARCH SYNTAX:
  FROM TABLE(
    schema.SERVICE_NAME!SEARCH('your natural language query')
  )
  
  RESULTS INCLUDE:
  - All columns from the original query (doc_id, content, title, doc_type)
  - search_score: Relevance score (higher = more relevant)
*/

-- STEP 1: Search for connection issues (semantic search)
SELECT 
  doc_id,
  title,
  doc_type,
  content,
  search_score  -- Higher score = more relevant (typically 0.0 to 1.0)
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'How do I fix Wi-Fi connection problems?'
  )
)
ORDER BY search_score DESC
LIMIT 5;

-- Notice: It finds the SmartCam troubleshooting doc even though 
-- the query said "Wi-Fi" and the doc says "network"!
-- This is the power of semantic search - understanding meaning, not just keywords.

-- STEP 2: Try different natural language queries
-- Run this to see how semantic search handles various phrasings
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

-- QUESTION: Do the search results make sense for each query?
-- Which query returned the highest search scores?

-- STEP 3: YOUR TURN - Search for specific customer issues
-- TODO: Write three separate searches for these customer questions:
--   1. "My device won't turn on"
--   2. "How to charge the power bank"
--   3. "Product specifications"
--
-- HINT: Use the pattern from Step 1, just change the search text

-- Search 1: Device won't turn on
SELECT 
  doc_id,
  title,
  doc_type,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    -- TODO: Replace with your search query for "device won't turn on"
    
  )
)
ORDER BY search_score DESC
LIMIT 5;

-- Search 2: How to charge power bank
-- TODO: Write complete query here



-- Search 3: Product specifications  
-- TODO: Write complete query here



-- ============================================================================
-- EXERCISE 3.4: RETRIEVAL AUGMENTED GENERATION (RAG) (4 minutes)
-- Combine search + LLM for accurate, grounded answers
-- ============================================================================

/*
  🌟 RAG Pattern - THE MOST IMPORTANT PATTERN IN THIS WORKSHOP! 🌟
  
  RAG = Retrieval Augmented Generation
  
  THE PROBLEM: LLMs can "hallucinate" - make up plausible-sounding but 
  incorrect information. This is unacceptable for business applications.
  
  THE SOLUTION: RAG Pattern
  1. RETRIEVAL: Search for relevant documents from your actual data
  2. AUGMENTATION: Pass those documents to the LLM as context
  3. GENERATION: LLM generates answer based ONLY on the provided docs
  
  This prevents hallucination - the LLM only uses real information!
  
  WHY IT MATTERS:
  - Answers are grounded in your actual documentation
  - You maintain control over the information source
  - Easy to audit and verify responses
  - No need to fine-tune expensive models
*/

-- STEP 1: Simple RAG - answer a question using documentation
-- Study this pattern carefully - you'll use it throughout your career!

WITH search_results AS (
  -- Step 1: RETRIEVAL - Find relevant docs
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
  -- Step 2 & 3: AUGMENTATION + GENERATION
  -- Notice the clear instructions to ONLY use provided context
  'Answer this question using ONLY the information provided below. 
  If the answer is not in the provided context, say "I don''t have that information."
  
  Question: How do I pair the UltraSound Pro headphones with my device?
  
  Context from documentation:
  ' || LISTAGG(content, '\n\n---\n\n') WITHIN GROUP (ORDER BY content) || '
  
  Answer:'
) AS ai_answer
FROM search_results;

-- NOTICE: The LLM's answer is based on actual documentation!
-- Try running the search query alone to see what docs were retrieved.

-- STEP 2: YOUR TURN - Try the RAG pattern with different questions
-- TODO: Modify this query to ask about a different topic
--       Try: battery life, charging, setup, troubleshooting, features
--
-- REQUIREMENTS:
-- - Change the search query to match your question
-- - Update the question in the prompt to match
-- - Keep the same RAG structure (WITH clause, COMPLETE call)
--
-- SUGGESTED QUESTIONS TO TRY:
-- - 'How long does battery last?'
-- - 'How do I charge my device?'
-- - 'What should I do if it won't turn on?'
-- - 'What are the warranty terms?'
-- - 'How do I enable night vision on the camera?'

WITH search_results AS (
  SELECT content
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      -- TODO: Change this to your question
      
    )
  )
  LIMIT 3
)
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',
  'Answer this question using ONLY the documentation provided. Keep it concise.

  Question: -- TODO: Change this to match your search question

  Documentation:
  ' || LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY content) || '

  Answer:'
) AS ai_answer
FROM search_results;

-- REFLECTION QUESTIONS:
-- 1. How does the LLM answer differ from just showing the raw docs?
-- 2. What happens if you ask a question not covered in the docs?
-- 3. Why is it important to tell the LLM "ONLY use provided information"?

-- ⏱️ TIME CHECK: You should be at ~12 minutes elapsed. Great progress!

-- ============================================================================
-- EXERCISE 3.5: SUPPORT TICKET AUTO-RESPONSE (3 minutes)
-- Use search + LLM to generate responses to support tickets
-- ============================================================================

/*
  SCENARIO: When a support ticket arrives, automatically:
  1. Translate to English if needed
  2. Search for relevant documentation
  3. Generate a helpful, empathetic response
  4. Show which documentation was used
  
  This is a real-world application of RAG that could save hours of agent time!
*/

-- STEP 1: Auto-respond to a support ticket using RAG (EXAMPLE)
-- This demonstrates the complete workflow
WITH ticket AS (
  SELECT 
    ticket_id,
    subject,
    description,
    language,
    -- Translate to English if needed for better search results
    CASE 
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END AS english_description
  FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
  WHERE ticket_id = 'TKT-006'  -- French ticket about defective laptop
),
relevant_help AS (
  -- Search for docs that can help with this ticket
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

-- Notice how the response:
-- - Acknowledges the customer's frustration
-- - Provides specific troubleshooting steps from documentation
-- - Is empathetic and professional

-- STEP 2: YOUR TURN - Try with different support tickets
-- TODO: Modify the query to work with different tickets
--
-- AVAILABLE TICKETS TO TRY:
-- - TKT-008: German customer received wrong item
-- - TKT-004: Spanish customer has payment issue
-- - TKT-011: English customer needs address change
-- - TKT-001: English customer has damaged package
-- - TKT-009: Japanese customer has delivery delay
--
-- REQUIREMENTS:
-- - Keep the same structure (two CTEs: ticket, relevant_help)
-- - Change only the ticket_id in the WHERE clause
-- - Observe how the response changes based on the issue

WITH ticket AS (
  SELECT
    ticket_id,
    subject,
    description,
    language,
    CASE
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END AS english_description
  FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
  WHERE ticket_id = -- TODO: Try different ticket IDs here
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

-- REFLECTION QUESTIONS:
-- 1. How does the response quality compare across different languages?
-- 2. Does the system find appropriate documentation for each issue?
-- 3. How could you improve this for production use?

-- ✅ CORE EXERCISES COMPLETE! You've learned semantic search and RAG patterns.
-- ⏱️ TIME CHECK: ~15 minutes. Ready to see it all come together!

-- ============================================================================
-- 🎯 OPTIONAL EXERCISE - IF TIME PERMITS (5 MINUTES)
-- ============================================================================

-- ============================================================================
-- EXERCISE 3.6: FINAL SHOWCASE QUERY
-- See the full power of Cortex in one query!
-- ============================================================================

/*
  This query demonstrates EVERYTHING you've learned across all 3 worksheets:
  - Multi-language support (TRANSLATE)
  - Sentiment analysis (SENTIMENT)
  - Semantic search (CORTEX SEARCH)
  - RAG pattern (Search + LLM)
  - All in pure SQL!
  
  This is the "wow moment" - show this to your manager/team!
*/

WITH customer_inquiries AS (
  -- Simulating incoming customer questions in multiple languages
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
    -- Get sentiment to prioritize frustrated customers
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
FROM processed_inquiries
ORDER BY sentiment ASC;  -- Most negative sentiment first for priority

-- 🎉 FANTASTIC! You've seen how Cortex brings AI directly into your SQL queries!

-- ============================================================================
-- 🚀 ADVANCED EXERCISES - FOR POST-WORKSHOP PRACTICE
-- These exercises are for after the workshop or for fast learners
-- ============================================================================

-- ============================================================================
-- EXERCISE 3.7: FILTER SEARCH BY ATTRIBUTES (ADVANCED)
-- Narrow searches to specific product categories or document types
-- ============================================================================

/*
  You can filter search results by the attributes you defined when 
  creating the search service (title, doc_type in our case)
  
  FILTER SYNTAX:
  {'filter': {'@eq': {'field_name': 'value'}}}
  
  AVAILABLE OPERATORS:
  - @eq: Equals
  - @ne: Not equals
  - @gt: Greater than (for numeric fields)
  - @lt: Less than (for numeric fields)
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

-- STEP 3: YOUR TURN - Product-specific filtered search
-- TODO: Search for battery information only in user manuals
--
-- REQUIREMENTS:
-- - Search query should be about battery (life, charging, optimization, etc.)
-- - Filter for doc_type = 'user_manual'
-- - Return doc_id, title, doc_type, content preview (first 300 chars), search_score
-- - Limit to top 5 results
--
-- HINT: Combine the search pattern from Step 2 with a battery-related query

-- TODO: Write your complete query here




-- ============================================================================
-- EXERCISE 3.8: CREATE A REUSABLE CHATBOT FUNCTION (ADVANCED)
-- Build a production-ready knowledge base assistant
-- ============================================================================

/*
  ADVANCED CHALLENGE: Create a reusable SQL function that:
  1. Takes a customer question as input
  2. Searches relevant documentation
  3. Generates an accurate, helpful answer
  4. Returns confidence level and sources
  5. Handles edge cases gracefully
  
  This is production-ready code you could actually deploy!
*/

-- TODO: Study this function carefully - it's a complete chatbot implementation
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

-- Test the chatbot function with a single question
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT(
  'How do I enable noise cancellation on the headphones?'
));

-- Test with multiple questions at once
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT('What is the battery life of the smart watch?'))
UNION ALL
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT('Can the camera work without WiFi?'))
UNION ALL
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT('How do I update my laptop firmware?'))
UNION ALL
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT('What is your return policy?'));

-- YOUR TURN: Test with your own questions
-- TODO: Ask 3-5 questions you think customers might ask
-- Try edge cases: questions not in docs, ambiguous questions, etc.

SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT(
  -- TODO: Your question 1 here
  
));

-- TODO: Question 2


-- TODO: Question 3


-- REFLECTION QUESTIONS:
-- 1. How does the confidence score help you decide if the answer is reliable?
-- 2. What happens when you ask about topics not in the documentation?
-- 3. How could you enhance this function for production use?

-- ============================================================================
-- EXERCISE 3.9: MULTI-LINGUAL CHATBOT (ADVANCED)
-- Handle questions in any language automatically
-- ============================================================================

/*
  ADVANCED: Take the chatbot to the next level with automatic translation
  This enables truly global support with a single function!
*/

-- TODO: Study this multi-lingual implementation
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

-- Test multilingual chatbot with various languages
SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  '¿Cuánto tiempo dura la batería de los auriculares?',  -- Spanish
  'es'
));

SELECT * FROM TABLE(ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  'Comment puis-je réinitialiser ma caméra?',  -- French
  'fr'
));

-- TODO: Test with other languages
-- Try: German (de), Japanese (ja), Chinese (zh), Italian (it)

-- TODO: Your multilingual test queries here




-- ============================================================================
-- EXERCISE 3.10: CREATE YOUR OWN SEARCH SERVICE (BONUS CHALLENGE)
-- Practice creating a search service on different data
-- ============================================================================

/*
  CHALLENGE: Create a search service on customer reviews
  This will let you search reviews semantically and analyze customer feedback
  
  STEPS TO COMPLETE:
  1. Create the search service
  2. Wait for it to be ACTIVE
  3. Test semantic search on reviews
  4. Use RAG to analyze customer sentiment on features
*/

-- TODO: Complete this CREATE statement
-- REQUIREMENTS:
-- - Service name: PRODUCT_REVIEWS_SEARCH
-- - Search on: review_text column
-- - Attributes: product_name, rating
-- - Use CORTEX_LAB_WH warehouse
-- - Source: LAB_DATA.SAMPLES.PRODUCT_REVIEWS table

CREATE OR REPLACE CORTEX SEARCH SERVICE PRODUCT_REVIEWS_SEARCH
ON -- TODO: Which column to search?
ATTRIBUTES -- TODO: Which attributes to include?
WAREHOUSE = CORTEX_LAB_WH
TARGET_LAG = '1 minute'
AS (
  -- TODO: Write your SELECT statement
  
);

-- Wait for it to be active
DESCRIBE CORTEX SEARCH SERVICE PRODUCT_REVIEWS_SEARCH;

-- TODO: Once ACTIVE, search for reviews mentioning specific features
-- Example: Search for "sound quality and noise cancellation"

SELECT 
  review_id,
  product_name,
  rating,
  LEFT(review_text, 200) AS review_preview,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_REVIEWS_SEARCH!SEARCH(
    -- TODO: Your search query here
    
  )
)
ORDER BY search_score DESC
LIMIT 5;

-- TODO: Use RAG to summarize customer feedback on a specific feature
-- REQUIREMENTS:
-- - Search reviews for mentions of "battery life"
-- - Use top 10 results
-- - Generate a summary with COMPLETE that includes positive and negative feedback
-- - Include product names and ratings in the context
--
-- HINT: Follow the RAG pattern from Exercise 3.4

WITH review_search AS (
  -- TODO: Search for battery life reviews
  
  LIMIT 10
)
SELECT 
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    -- TODO: Write your prompt here
    -- Ask to summarize what customers say about battery life
    -- Include both positive and negative feedback
    
  ) AS battery_life_summary
FROM review_search;

/*******************************************************************************
 * WORKSHEET 3 COMPLETE! ✓
 *
 * 🎉 CONGRATULATIONS! YOU'VE COMPLETED THE SNOWFLAKE CORTEX AI LAB! 🎉
 *
 * KEY TAKEAWAYS FROM WORKSHEET 3:
 * ✓ Semantic search finds documents by meaning, not just keywords
 * ✓ Cortex Search Service makes semantic search easy with SQL
 * ✓ RAG (Retrieval Augmented Generation) prevents LLM hallucination
 * ✓ Search + LLM = powerful, accurate knowledge base systems
 * ✓ Filter searches by attributes for more precise results
 * ✓ Functions make chatbots reusable and production-ready
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
 * NEXT STEPS TO CONTINUE YOUR LEARNING:
 * 1. 🏠 Try this in your own Snowflake trial account
 *    → Go to signup.snowflake.com for a free 30-day trial
 *    → All Cortex features are included!
 *
 * 2. 📊 Explore Cortex Analyst for natural language to SQL
 *    → Generate SQL queries from plain English questions
 *    → Perfect for business users and analysts
 *
 * 3. 🎨 Try Cortex Fine-Tuning for specialized models
 *    → Customize models for your specific use cases
 *    → Improve accuracy on domain-specific tasks
 *
 * 4. 📚 Deep dive into documentation
 *    → Visit docs.snowflake.com/cortex
 *    → Join the Snowflake Community forums
 *    → Check out Snowflake's YouTube channel for tutorials
 *
 * 5. 🧪 Complete the advanced exercises (3.7-3.10) above
 *    → Build production-ready chatbot functions
 *    → Create multi-lingual support systems
 *    → Experiment with different data sources
 *
 * REAL-WORLD USE CASES YOU CAN NOW BUILD:
 * 
 * CUSTOMER SUPPORT:
 * • Automated ticket triage and classification
 * • Multi-language support response generation
 * • Intelligent document search and Q&A
 * • Sentiment-based priority routing
 * 
 * PRODUCT ANALYTICS:
 * • Review sentiment analysis across products
 * • Feature extraction from customer feedback
 * • Competitive mention detection
 * • Trend analysis and alerting
 * 
 * SALES & MARKETING:
 * • Call transcript analysis and summarization
 * • Lead scoring based on sentiment
 * • Personalized content generation
 * • Campaign performance analysis
 * 
 * OPERATIONS:
 * • Document classification and routing
 * • Knowledge base question answering
 * • Process automation with NLP
 * • Multi-language communication
 *
 * TIPS FOR PRODUCTION DEPLOYMENT:
 * 
 * 1. START SMALL: Begin with one use case, prove value, then expand
 * 2. MONITOR COSTS: Track credit usage and optimize model selection
 * 3. TEST THOROUGHLY: Validate LLM outputs, especially for critical applications
 * 4. VERSION CONTROL: Keep your prompts and queries in source control
 * 5. MEASURE SUCCESS: Define KPIs and track improvement over baseline
 * 6. GATHER FEEDBACK: Iterate based on user feedback and accuracy metrics
 * 7. HANDLE ERRORS: Build robust error handling for production use
 * 8. DOCUMENT WELL: Your future self (and team) will thank you!
 *
 * RESOURCES:
 * • Snowflake Cortex Documentation: docs.snowflake.com/cortex
 * • Snowflake Community: community.snowflake.com
 * • Quickstarts: quickstarts.snowflake.com (search for "Cortex")
 * • YouTube: Snowflake Developers channel
 * • GitHub: github.com/Snowflake-Labs (sample code and templates)
 *
 * Thank you for participating in the Snowflake Cortex AI Lab! 🙏
 * We hope you're excited to bring AI into your SQL workflows!
 *
 *******************************************************************************/
