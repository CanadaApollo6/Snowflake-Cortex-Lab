/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - WORKSHEET 2
 * CORTEX COMPLETE: Unleashing LLM Power with SQL
 * 
 * Time: 12 minutes
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
  SNOWFLAKE.CORTEX.COMPLETE(model_name, prompt, options)
  
  Available models:
  - 'mixtral-8x7b' - Fast, cost-effective, great for most tasks
  - 'mistral-large' - More capable, better reasoning
  - 'llama3-70b' - Strong general-purpose model
  - 'llama3-8b' - Faster, lighter version
  
  For this lab, we'll primarily use 'mixtral-8x7b' for speed and cost.
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

-- STEP 3: YOUR TURN - Add urgency classification
-- TODO: Modify the prompt to also classify urgency (low, medium, high)
SELECT 
  ticket_id,
  subject,
  priority AS actual_priority,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    -- TODO: Update this prompt to classify both category AND urgency
    'Analyze this support ticket and respond with ONLY the urgency level (low, medium, or high):
    
    Subject: ' || subject || '
    Description: ' || LEFT(description, 200) || '
    
    Urgency level:'
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

-- STEP 3: YOUR TURN - Extract product features from documentation
-- TODO: Write a query to extract key features from product docs
SELECT 
  doc_id,
  title,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    -- TODO: Write a prompt to extract the top 5 key features as a bullet list
    'From this product documentation, extract the top 5 key features as a simple numbered list.
    
    Documentation:
    ' || content || '
    
    Top 5 Features:'
  ) AS key_features
FROM PRODUCT_DOCS
WHERE doc_type = 'user_manual'
LIMIT 3;

-- ============================================================================
-- EXERCISE 2.4: CONTENT GENERATION
-- Create new content based on existing data
-- ============================================================================

/*
  SCENARIO: Generate personalized responses to customer reviews
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
-- TODO: Create compelling product descriptions based on positive reviews
SELECT 
  product_name,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    -- TODO: Write a prompt to generate a marketing description from these reviews
    'Based on these customer reviews, write a compelling 50-word product description highlighting the most praised features.
    
    Reviews:
    ' || LISTAGG(review_text, ' | ') WITHIN GROUP (ORDER BY rating DESC) || '
    
    Product Description:'
  ) AS marketing_description
FROM PRODUCT_REVIEWS
WHERE rating >= 4
  AND product_name = 'UltraSound Pro Wireless Headphones'
GROUP BY product_name;

-- ============================================================================
-- EXERCISE 2.5: MODEL COMPARISON
-- Different models have different strengths
-- ============================================================================

/*
  SCENARIO: Compare how different models handle the same task
  This helps you choose the right model for your use case.
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

-- STEP 2: YOUR TURN - Test models on a complex task
-- TODO: Try different models on extracting structured data
SELECT 
  'mixtral-8x7b' AS model,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Extract: customer concern, product mentioned, resolution requested. Format as JSON.
    
    Ticket: ' || description
  ) AS extracted_data
FROM CUSTOMER_SUPPORT_TICKETS
WHERE ticket_id = 'TKT-008'

UNION ALL

SELECT 
  'llama3-70b' AS model,
  SNOWFLAKE.CORTEX.COMPLETE(
    'llama3-70b',
    'Extract: customer concern, product mentioned, resolution requested. Format as JSON.
    
    Ticket: ' || description
  ) AS extracted_data
FROM CUSTOMER_SUPPORT_TICKETS
WHERE ticket_id = 'TKT-008';

-- ============================================================================
-- EXERCISE 2.6: ADVANCED - BUILDING A TICKET TRIAGE SYSTEM
-- Combine everything you've learned
-- ============================================================================

/*
  SCENARIO: Build an automated ticket triage system that:
  1. Translates non-English tickets
  2. Extracts key information
  3. Classifies urgency
  4. Suggests next actions
*/

-- YOUR CHALLENGE: Complete this comprehensive query
SELECT 
  ticket_id,
  customer_id,
  language,
  created_date,
  
  -- Translate to English if needed
  CASE 
    WHEN language = 'en' THEN subject
    ELSE SNOWFLAKE.CORTEX.TRANSLATE(subject, language, 'en')
  END AS english_subject,
  
  -- Get sentiment
  SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score,
  
  -- Classify category
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Categorize this ticket (one word): shipping, product_quality, payment, technical, or other.
    
    ' || subject || '
    
    Category:'
  ) AS ticket_category,
  
  -- Determine urgency
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Rate urgency (low/medium/high) based on this ticket:
    
    ' || description || '
    
    Urgency:'
  ) AS urgency_level,
  
  -- Suggest action
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'What is the best next action for this support ticket? One sentence.
    
    ' || LEFT(description, 300) || '
    
    Recommended action:'
  ) AS suggested_action

FROM CUSTOMER_SUPPORT_TICKETS
WHERE status = 'open'
ORDER BY sentiment_score ASC
LIMIT 5;

/*******************************************************************************
 * WORKSHEET 2 COMPLETE! ✓
 * 
 * KEY TAKEAWAYS:
 * - COMPLETE gives you full LLM capabilities in SQL
 * - Prompting is key - be specific and provide examples
 * - Different models have different strengths (and costs)
 * - You can build sophisticated AI workflows entirely in Snowflake
 * - Classification, extraction, and generation are all possible
 * 
 * NEXT: Move to Worksheet 3 to learn about Cortex Search and RAG patterns
 *******************************************************************************/