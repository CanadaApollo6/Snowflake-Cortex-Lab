/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - WORKSHEET 2
 * CORTEX COMPLETE: Unleashing LLM Power with SQL
 * 
 * Time: 20 minutes
 * Difficulty: Intermediate
 * 
 * In this worksheet, you'll use CORTEX.COMPLETE to tap into large language
 * models (LLMs) for classification, extraction, generation, and more.
 * 
 * LEARNING OBJECTIVES:
 * - Understand COMPLETE function syntax and parameters
 * - Use prompts to classify and categorize text
 * - Extract structured data from unstructured text
 * - Compare different LLM models
 * - Build practical business solutions with LLMs
 * 
 * ESTIMATED TIME PER EXERCISE:
 * - Exercise 2.1: 2 minutes
 * - Exercise 2.2: 4 minutes
 * - Exercise 2.3: 4 minutes
 * - Exercise 2.4: 4 minutes
 * - Exercise 2.5: 3 minutes
 * - Exercise 2.6: 3 minutes (challenge)
 * 
 *******************************************************************************/

USE ROLE CORTEX_LAB_USER;
USE WAREHOUSE CORTEX_LAB_WH;
USE DATABASE LAB_DATA;
USE SCHEMA SAMPLES;

-- ============================================================================
-- EXERCISE 2.1: INTRODUCTION TO CORTEX.COMPLETE
-- Your gateway to large language models
-- ============================================================================

/*
  CORTEX.COMPLETE syntax:
  SNOWFLAKE.CORTEX.COMPLETE(model_name, prompt)
  
  Available models (availability varies by region):
  - 'mixtral-8x7b' - Fast, cost-effective, great for most tasks
  - 'mistral-large' - More capable, better reasoning
  - 'llama3-70b' - Strong general-purpose model
  - 'llama3-8b' - Faster, lighter version
  - 'llama3.1-70b' - Latest Llama version with improved capabilities
  - 'llama3.1-8b' - Faster version of Llama 3.1
  
  For this lab, we'll primarily use 'mixtral-8x7b' for speed and cost.
  If you get a model availability error, try 'llama3-70b' or 'mistral-large'.
  
  PROMPT ENGINEERING TIPS:
  - Be specific and clear about what you want
  - Provide examples when possible
  - Specify the desired output format
  - Use consistent terminology
  - Test and iterate on your prompts
*/

-- STEP 1: Your first LLM query - a simple test
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',
  'Say "Hello from Snowflake Cortex!" if you can read this.'
) AS llm_response;

-- STEP 2: Ask the LLM to help with a business task
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',
  'Write a professional apology email to a customer whose package was damaged during shipping. Keep it under 100 words.'
) AS apology_email;

-- Notice: The LLM generates original content based on your instructions!

-- ============================================================================
-- EXERCISE 2.2: TEXT CLASSIFICATION
-- Categorize support tickets automatically
-- ============================================================================

/*
  SCENARIO: You receive hundreds of support tickets daily. You want to 
  automatically categorize them to route to the right team.
  
  CLASSIFICATION BEST PRACTICES:
  - Provide clear category options
  - Ask for consistent output format (e.g., "one word only")
  - Include enough context from the ticket
  - Be explicit about what to do with edge cases
*/

-- STEP 1: Classify a single ticket
SELECT 
  ticket_id,
  subject,
  description,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Categorize this customer support ticket into ONE of these categories: 
    - shipping_issue
    - product_defect
    - payment_problem
    - general_inquiry
    - positive_feedback
    
    Ticket subject: ' || subject || '
    Ticket description: ' || description || '
    
    Category (one word only):'
  ) AS suggested_category,
  category AS actual_category  -- Compare with our manual categorization
FROM CUSTOMER_SUPPORT_TICKETS
WHERE ticket_id = 'TKT-001';

-- STEP 2: Classify multiple tickets at once
SELECT 
  ticket_id,
  subject,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Categorize this support ticket into ONE word: shipping_issue, product_defect, payment_problem, general_inquiry, or positive_feedback.
    
    Subject: ' || subject || '
    
    Category:'
  ) AS ai_category,
  category AS actual_category
FROM CUSTOMER_SUPPORT_TICKETS
LIMIT 10;

-- QUESTION: How accurate is the AI categorization compared to actual_category?

-- STEP 3: YOUR TURN - Add urgency classification
-- TODO: Modify the query below to classify urgency level (low, medium, high)
--       based on the ticket subject and description
-- 
-- REQUIREMENTS:
-- - Use the first 200 characters of description to keep prompt concise
-- - Ask the LLM to respond with ONLY the urgency level
-- - Include both subject and description in your prompt
-- - Compare with the actual_priority column
--
-- HINT: Your prompt should ask for one of three values: low, medium, or high

SELECT 
  ticket_id,
  subject,
  LEFT(description, 200) AS description_preview,
  priority AS actual_priority,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    -- TODO: Write your urgency classification prompt here
    -- Start with: 'Analyze this support ticket and respond with ONLY...'
    
    
  ) AS ai_urgency
FROM CUSTOMER_SUPPORT_TICKETS
LIMIT 8;

-- ============================================================================
-- EXERCISE 2.3: STRUCTURED DATA EXTRACTION
-- Pull specific information from unstructured text
-- ============================================================================

/*
  SCENARIO: Sales call transcripts contain valuable information, but it's 
  buried in conversation. Extract key details automatically.
  
  EXTRACTION BEST PRACTICES:
  - Specify the exact fields you want extracted
  - Define the output format (list, JSON, table, etc.)
  - Limit input text length for better performance
  - Be specific about how to handle missing information
*/

-- STEP 1: Extract action items from a sales call
SELECT 
  call_id,
  sales_rep,
  customer_name,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Read this sales call transcript and list the action items. Be specific and concise.
    
    Transcript:
    ' || transcript || '
    
    Action items:'
  ) AS action_items
FROM SALES_TRANSCRIPTS
WHERE call_id = 'CALL-001';

-- STEP 2: Extract multiple structured fields
SELECT 
  call_id,
  customer_name,
  outcome,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Analyze this sales call and extract:
    1. Main objection (if any)
    2. Products discussed
    3. Next steps
    
    Format as a simple list.
    
    Transcript:
    ' || transcript || '
    
    Analysis:'
  ) AS call_analysis
FROM SALES_TRANSCRIPTS
WHERE call_id = 'CALL-002';

-- QUESTION: Does the extracted information match what you see in the transcript?

-- STEP 3: YOUR TURN - Extract product features from documentation
-- TODO: Write a complete query to extract key features from product documentation
--
-- REQUIREMENTS:
-- - Select doc_id, title from PRODUCT_DOCS
-- - Use CORTEX.COMPLETE to extract the top 5 key features
-- - Ask for output as a numbered list (1. Feature one, 2. Feature two, etc.)
-- - Filter for doc_type = 'user_manual'
-- - Limit to 3 results
--
-- HINT: Your prompt should start with "From this product documentation, extract..."

-- TODO: Write your complete query here




-- ============================================================================
-- EXERCISE 2.4: CONTENT GENERATION
-- Create new content based on existing data
-- ============================================================================

/*
  SCENARIO: Generate personalized responses to customer reviews
  
  GENERATION BEST PRACTICES:
  - Specify tone (professional, friendly, empathetic, etc.)
  - Set length constraints (word/sentence limits)
  - Provide context about what the content is for
  - Include relevant data in the prompt
*/

-- STEP 1: Generate response to a negative review
SELECT 
  review_id,
  product_name,
  rating,
  review_text,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Write a professional, empathetic response to this customer review. 
    Acknowledge their concerns and offer to help. Keep it under 75 words.
    
    Product: ' || product_name || '
    Rating: ' || rating || ' stars
    Review: ' || review_text || '
    
    Response:'
  ) AS suggested_response
FROM PRODUCT_REVIEWS
WHERE rating <= 2
LIMIT 3;

-- STEP 2: Generate FAQ entries from documentation
SELECT 
  doc_id,
  title,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Based on this documentation, generate 3 frequently asked questions and brief answers.
    Format as:
    Q1: [question]
    A1: [answer]
    
    Documentation:
    ' || LEFT(content, 1000) || '
    
    FAQ:'
  ) AS generated_faq
FROM PRODUCT_DOCS
WHERE doc_type = 'user_manual'
  AND doc_id = 'DOC-001';

-- STEP 3: YOUR TURN - Generate product descriptions from reviews
-- TODO: Create a compelling marketing description based on positive reviews
--
-- REQUIREMENTS:
-- - Use PRODUCT_REVIEWS table
-- - Filter for rating >= 4 for 'UltraSound Pro Wireless Headphones'
-- - Use LISTAGG to combine multiple review_text values
-- - Generate a 50-word marketing description highlighting praised features
-- - Group by product_name
--
-- HINT: LISTAGG syntax: LISTAGG(column, 'separator') WITHIN GROUP (ORDER BY ...)

-- TODO: Write your complete query here




-- ============================================================================
-- EXERCISE 2.5: MODEL COMPARISON
-- Different models have different strengths
-- ============================================================================

/*
  SCENARIO: Compare how different models handle the same task.
  This helps you choose the right model for your use case.
  
  FACTORS TO CONSIDER:
  - Quality: Is the output accurate and coherent?
  - Length: Does it follow length constraints?
  - Speed: How fast does it respond? (you won't see this in results)
  - Cost: Larger models cost more per token
  - Consistency: Does it follow instructions precisely?
*/

-- STEP 1: Same prompt, different models
SELECT 
  'mixtral-8x7b' AS model,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Summarize this support ticket in exactly one sentence: ' || description
  ) AS response
FROM CUSTOMER_SUPPORT_TICKETS
WHERE ticket_id = 'TKT-001'

UNION ALL

SELECT 
  'mistral-large' AS model,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large',
    'Summarize this support ticket in exactly one sentence: ' || description
  ) AS response
FROM CUSTOMER_SUPPORT_TICKETS
WHERE ticket_id = 'TKT-001';

-- QUESTION: Notice any differences in quality, length, or style?
-- Which response is more concise? Which captures more detail?

-- STEP 2: YOUR TURN - Test models on a complex extraction task
-- TODO: Compare how different models extract structured data
--
-- REQUIREMENTS:
-- - Test 'mixtral-8x7b' and 'llama3-70b' (or 'mistral-large' if llama3 unavailable)
-- - Use UNION ALL to combine results
-- - Extract: customer concern, product mentioned, resolution requested
-- - Ask for JSON format output
-- - Use ticket_id = 'TKT-008'
--
-- HINT: Follow the pattern from Step 1, but change the prompt for extraction

-- TODO: Write your complete query here




-- QUESTION: Which model produces better structured output?
-- Does one follow the JSON format instruction more closely?

-- ============================================================================
-- EXERCISE 2.6: ADVANCED - BUILDING A TICKET TRIAGE SYSTEM
-- Combine everything you've learned
-- ============================================================================

/*
  SCENARIO: Build an automated ticket triage system that:
  1. Translates non-English tickets to English
  2. Analyzes sentiment
  3. Classifies category
  4. Determines urgency
  5. Suggests next actions
  
  This is a realistic business application combining multiple Cortex functions!
*/

-- EXAMPLE: Complete triage system (study this pattern)
SELECT 
  ticket_id,
  customer_id,
  language,
  created_date,
  status,
  priority AS actual_priority,
  
  -- Translate subject to English if needed
  CASE 
    WHEN language = 'en' THEN subject
    ELSE SNOWFLAKE.CORTEX.TRANSLATE(subject, language, 'en')
  END AS english_subject,
  
  -- Get sentiment score
  sentiment_score,
  
  -- Classify category
  ticket_category,
  
  -- Determine urgency
  urgency_level,
  
  -- Suggest action
  suggested_action

FROM (
  -- First translate and get base data
  SELECT 
    ticket_id,
    customer_id,
    language,
    created_date,
    status,
    priority,
    subject,
    CASE 
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END AS english_description
  FROM CUSTOMER_SUPPORT_TICKETS
  WHERE status = 'open'
),
-- Then calculate all AI features from the translated text
LATERAL (
  SELECT 
    SNOWFLAKE.CORTEX.SENTIMENT(english_description) AS sentiment_score,
    
    SNOWFLAKE.CORTEX.COMPLETE(
      'mixtral-8x7b',
      'Categorize this ticket into ONE word: shipping, product_quality, payment, technical, or other.
      
      Ticket: ' || english_description || '
      
      Category:'
    ) AS ticket_category,
    
    SNOWFLAKE.CORTEX.COMPLETE(
      'mixtral-8x7b',
      'Rate urgency as ONE word only (low, medium, or high) based on this ticket:
      
      ' || LEFT(english_description, 300) || '
      
      Urgency:'
    ) AS urgency_level,
    
    SNOWFLAKE.CORTEX.COMPLETE(
      'mixtral-8x7b',
      'What is the best next action for this support ticket? Respond in one sentence.
      
      ' || LEFT(english_description, 300) || '
      
      Recommended action:'
    ) AS suggested_action
)
ORDER BY sentiment_score ASC
LIMIT 5;

-- YOUR CHALLENGE: Can you improve this system?
-- Ideas to try:
-- - Add a confidence score for categorization
-- - Generate a draft response to the customer
-- - Estimate resolution time based on similar tickets
-- - Identify if a ticket mentions a competitor

/*******************************************************************************
 * WORKSHEET 2 COMPLETE! ✓
 * 
 * KEY TAKEAWAYS:
 * - COMPLETE gives you full LLM capabilities in SQL
 * - Prompting is key - be specific, provide examples, specify format
 * - Different models have different strengths and costs
 * - Use subqueries to avoid calling expensive functions multiple times
 * - You can build sophisticated AI workflows entirely in Snowflake
 * - Classification, extraction, and generation are all possible
 * - Combine multiple Cortex functions for powerful solutions
 * 
 * PROMPT ENGINEERING REMINDERS:
 * ✓ Be specific about what you want
 * ✓ Specify output format clearly
 * ✓ Provide enough context, but not too much
 * ✓ Ask for one thing at a time when possible
 * ✓ Test different phrasings to improve results
 * 
 * NEXT: Move to Worksheet 3 to learn about Cortex Search and RAG patterns
 *******************************************************************************/

-- ============================================================================
-- OPTIONAL: CHECK YOUR WORK
-- Run these verification queries to test your solutions
-- ============================================================================

-- Verify Exercise 2.2 Step 3: Should return 8 tickets with urgency levels
-- SELECT COUNT(*) AS tickets_with_urgency
-- FROM (your Exercise 2.2 Step 3 query);
-- Expected: 8 rows with low/medium/high urgency values

-- Verify Exercise 2.3 Step 3: Should return 3 feature lists
-- SELECT COUNT(*) AS docs_with_features
-- FROM (your Exercise 2.3 Step 3 query);
-- Expected: 3 rows with numbered feature lists

-- Verify Exercise 2.4 Step 3: Should return 1 marketing description
-- SELECT COUNT(*) AS descriptions
-- FROM (your Exercise 2.4 Step 3 query);
-- Expected: 1 row with ~50 word description

-- Verify Exercise 2.5 Step 2: Should return 2 rows (one per model)
-- SELECT COUNT(DISTINCT model) AS model_count
-- FROM (your Exercise 2.5 Step 2 query);
-- Expected: 2 different models tested
