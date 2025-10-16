/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - WORKSHEET 2 ANSWER KEY
 * CORTEX COMPLETE: Unleashing LLM Power with SQL
 *
 * This file contains complete solutions for all TODO exercises in Worksheet 2.
 * Use this to verify your answers or for instructor reference.
 *
 * IMPORTANT NOTE ABOUT LLM OUTPUTS:
 * LLMs are non-deterministic! Your exact output may differ from these examples.
 * That's normal and expected. Focus on whether the output is:
 * - Relevant to the prompt
 * - Accurate based on the input data
 * - Formatted as requested
 *
 *******************************************************************************/

USE ROLE CORTEX_LAB_USER;
USE WAREHOUSE CORTEX_LAB_WH;
USE DATABASE LAB_DATA;
USE SCHEMA SAMPLES;

-- ============================================================================
-- EXERCISE 2.2: TEXT CLASSIFICATION
-- ============================================================================

-- STEP 3: YOUR TURN - Add urgency classification
-- ANSWER:
SELECT
  ticket_id,
  subject,
  priority AS actual_priority,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Analyze this support ticket and respond with ONLY the urgency level (low, medium, or high):

    Subject: ' || subject || '
    Description: ' || LEFT(description, 200) || '

    Urgency level:'
  ) AS ai_urgency
FROM CUSTOMER_SUPPORT_TICKETS
LIMIT 8;

/*
EXPLANATION:
- Prompt is clear and specific: "ONLY the urgency level"
- We give it the options: low, medium, high
- We include both subject and description for context
- LEFT(description, 200) limits token usage while keeping key info

EXPECTED RESULTS (examples - your exact wording may vary):
- TKT-001 (damaged package): "high" (customer is very upset)
- TKT-002 (return question): "medium" (wants answer but not urgent)
- TKT-003 (positive feedback): "low" (no action needed)
- TKT-004 (payment issue): "high" (blocking their purchase)

KEY INSIGHT:
The AI considers both the content and emotional tone. A polite inquiry
about returns gets "medium" while an angry complaint gets "high".
*/

-- ALTERNATIVE: More structured prompt for consistent formatting
SELECT
  ticket_id,
  subject,
  priority AS actual_priority,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Classify this support ticket urgency. Respond with exactly one word: low, medium, or high.

    Ticket: ' || subject || ' - ' || LEFT(description, 150) || '

    Urgency:'
  ) AS ai_urgency
FROM CUSTOMER_SUPPORT_TICKETS
LIMIT 8;

/*
TIP: Adding "exactly one word" helps ensure consistent output format
*/

-- ============================================================================
-- EXERCISE 2.3: STRUCTURED DATA EXTRACTION
-- ============================================================================

-- STEP 3: YOUR TURN - Extract product features from documentation
-- ANSWER:
SELECT
  doc_id,
  title,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'From this product documentation, extract the top 5 key features as a simple numbered list.

    Documentation:
    ' || content || '

    Top 5 Features:'
  ) AS key_features
FROM PRODUCT_DOCS
WHERE doc_type = 'user_manual'
LIMIT 3;

/*
EXPLANATION:
- Clear instruction: "top 5 key features"
- Specified format: "simple numbered list"
- Filters to user_manual docs which have feature info

EXPECTED RESULTS (examples - exact wording will vary):

DOC-001 (UltraSound Pro):
1. 30 hours of playback on full charge
2. Active noise cancellation with transparency mode
3. Bluetooth pairing with automatic reconnection
4. USB-C charging (2 hours to full charge)
5. LED indicators for power and pairing status

DOC-003 (PowerBook Elite):
1. Intel Core i7 processor (11th Gen)
2. 16GB RAM and 512GB SSD storage
3. Battery optimization settings
4. Touch ID for quick login
5. USB-C power adapter with fast charging

DOC-004 (FitTrack):
1. 24/7 heart rate monitoring
2. 20+ exercise modes including swimming
3. 5-7 days battery life (typical use)
4. Sleep stage tracking (light, deep, REM)
5. Smart notifications and music control

KEY INSIGHT:
The LLM understands what constitutes a "feature" and extracts the most
relevant information even from lengthy documentation.
*/

-- VARIATION: More specific extraction
SELECT
  doc_id,
  title,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Extract the following information from this product manual:
    1. Battery life/charging time
    2. Key connectivity features
    3. Main use cases
    Format as bullet points.

    Manual:
    ' || content || '

    Extracted info:'
  ) AS structured_features
FROM PRODUCT_DOCS
WHERE doc_type = 'user_manual'
LIMIT 3;

/*
TIP: You can specify exactly what fields to extract for more control
*/

-- ============================================================================
-- EXERCISE 2.4: CONTENT GENERATION
-- ============================================================================

-- STEP 3: YOUR TURN - Generate product descriptions from reviews
-- ANSWER:
SELECT
  product_name,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Based on these customer reviews, write a compelling 50-word product description highlighting the most praised features.

    Reviews:
    ' || LISTAGG(review_text, ' | ') WITHIN GROUP (ORDER BY rating DESC) || '

    Product Description:'
  ) AS marketing_description
FROM PRODUCT_REVIEWS
WHERE rating >= 4
  AND product_name = 'UltraSound Pro Wireless Headphones'
GROUP BY product_name;

/*
EXPLANATION:
- We filter for rating >= 4 (positive reviews only)
- LISTAGG combines multiple reviews into one context string
- Prompt asks for "compelling" description (marketing tone)
- Specifies word count (50 words) for consistency
- Focus on "most praised features" from actual reviews

EXPECTED RESULT (example - your exact wording will vary):

"Experience premium audio with UltraSound Pro Wireless Headphones.
Featuring exceptional noise cancellation perfect for commutes, crystal-clear
sound across all frequencies, and industry-leading battery life lasting days
on a single charge. Users consistently praise the outstanding sound quality
and all-day comfort. Worth every penny."

KEY INSIGHT:
The LLM synthesizes multiple reviews to create marketing copy that
highlights real customer praise. This is authentic, not made-up benefits!
*/

-- ALTERNATIVE: Generate description with specific structure
SELECT
  product_name,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Create a product description with this structure:
    - Opening hook (10 words)
    - Top 3 benefits from reviews
    - Call to action

    Customer Reviews:
    ' || LISTAGG(review_text, ' | ') WITHIN GROUP (ORDER BY rating DESC) || '

    Product Description:'
  ) AS structured_description
FROM PRODUCT_REVIEWS
WHERE rating >= 4
  AND product_name = 'UltraSound Pro Wireless Headphones'
GROUP BY product_name;

/*
TIP: Specifying structure helps ensure consistent output format
across different products
*/

-- ============================================================================
-- EXERCISE 2.5: MODEL COMPARISON
-- ============================================================================

-- STEP 2: YOUR TURN - Test models on a complex task
-- ANSWER:
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

/*
EXPLANATION:
- Same prompt, different models
- Asking for JSON format tests structured output capability
- TKT-008 is German text about wrong item received

EXPECTED RESULTS (examples):

mixtral-8x7b might return:
{
  "customer_concern": "Received wrong item (headphones instead of camera)",
  "product_mentioned": "Camera",
  "resolution_requested": "Send correct camera urgently for weekend event"
}

llama3-70b might return similar structure with slightly different phrasing.

KEY INSIGHTS:
- Both models should handle the task successfully
- Llama3-70b may be slightly better at structured output
- Mixtral-8x7b is faster and more cost-effective
- For most tasks, mixtral-8x7b is sufficient
- Use larger models for complex reasoning or very specific requirements

WHEN TO USE EACH MODEL:
- mixtral-8x7b: General purpose, fast, cost-effective
- mistral-large: When you need better reasoning or instruction-following
- llama3-70b: Strong general performance, good for complex tasks
- llama3-8b: Faster/cheaper for simpler tasks
*/

-- ============================================================================
-- EXERCISE 2.6: BUILDING A TICKET TRIAGE SYSTEM
-- ============================================================================

-- This exercise doesn't have TODOs but here's the complete working solution
-- with detailed annotations:

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

/*
EXPLANATION OF THE COMPLETE SYSTEM:
This query demonstrates a production-ready ticket triage system that:

1. TRANSLATION: Handles multi-language input
2. SENTIMENT: Identifies emotional urgency
3. CLASSIFICATION: Routes to correct team
4. PRIORITIZATION: Determines handling urgency
5. ACTION: Suggests next steps

WORKFLOW:
1. Ticket arrives in any language
2. System translates to English
3. Analyzes sentiment (angry customer? → high priority)
4. Classifies type (shipping vs technical vs payment)
5. Determines urgency from content
6. Suggests specific action

EXPECTED RESULTS:
Most negative tickets first (sentiment_score ASC), each with:
- English translation of subject
- Negative sentiment score
- Category like "shipping" or "product_quality"
- Urgency level matching the emotion
- Specific suggested action like "Send replacement immediately"

PRODUCTION DEPLOYMENT:
This could become a scheduled task that:
- Runs every 5 minutes on new tickets
- Inserts results into a TICKET_TRIAGE table
- Triggers alerts for high-urgency negative tickets
- Routes to appropriate teams based on category

COST CONSIDERATIONS:
- 5 Cortex function calls per ticket
- For 1000 tickets/day: ~5000 function calls
- Typically < $10/day depending on text length
- ROI: Saves hours of manual triage time
*/

-- ============================================================================
-- BONUS: Advanced Patterns
-- ============================================================================

-- PATTERN 1: Batch processing with error handling
SELECT
  ticket_id,
  subject,
  TRY_CAST(
    SNOWFLAKE.CORTEX.COMPLETE(
      'mixtral-8x7b',
      'Classify urgency as: 1=low, 2=medium, 3=high. Respond with only the number.

      Ticket: ' || subject || '

      Number:'
    ) AS INTEGER
  ) AS urgency_numeric,
  CASE
    WHEN TRY_CAST(
      SNOWFLAKE.CORTEX.COMPLETE(
        'mixtral-8x7b',
        'Classify urgency as: 1=low, 2=medium, 3=high. Respond with only the number.

        Ticket: ' || subject || '

        Number:'
      ) AS INTEGER
    ) >= 3 THEN 'HIGH'
    WHEN TRY_CAST(
      SNOWFLAKE.CORTEX.COMPLETE(
        'mixtral-8x7b',
        'Classify urgency as: 1=low, 2=medium, 3=high. Respond with only the number.

        Ticket: ' || subject || '

        Number:'
      ) AS INTEGER
    ) = 2 THEN 'MEDIUM'
    ELSE 'LOW'
  END AS urgency_category
FROM CUSTOMER_SUPPORT_TICKETS
LIMIT 5;

/*
PATTERN EXPLANATION:
- Asks LLM for numeric output (1, 2, 3)
- TRY_CAST safely converts to INTEGER
- If conversion fails, returns NULL instead of error
- Allows for downstream numeric operations and sorting
*/

-- PATTERN 2: Few-shot learning for consistent classification
SELECT
  ticket_id,
  subject,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Classify support tickets into categories. Examples:

    "Package damaged in shipping" → shipping_damage
    "How do I return this?" → returns
    "Payment declined" → payment_issue

    Now classify this ticket:
    "' || subject || '"

    Category:'
  ) AS category
FROM CUSTOMER_SUPPORT_TICKETS
LIMIT 5;

/*
PATTERN EXPLANATION:
- Provides examples (few-shot learning)
- LLM learns the pattern from examples
- Results in more consistent categorization
- Useful when you have specific category definitions
*/

-- ============================================================================
-- KEY TAKEAWAYS FOR WORKSHEET 2
-- ============================================================================

/*
1. COMPLETE SYNTAX:
   SNOWFLAKE.CORTEX.COMPLETE(model_name, prompt)
   - Model: 'mixtral-8x7b', 'mistral-large', 'llama3-70b', 'llama3-8b'
   - Prompt: Your instructions + context

2. PROMPT ENGINEERING TIPS:
   - Be specific: "Respond with exactly one word"
   - Give examples: "Like this: category_name"
   - Specify format: "Format as JSON" or "as a numbered list"
   - Limit context: Use LEFT() for long text
   - Set constraints: "Keep it under 50 words"

3. COMMON PATTERNS:
   - Classification: Give options, ask to pick one
   - Extraction: Specify fields, request structure
   - Generation: Describe tone/style, set length
   - Analysis: Ask for specific insights

4. MODEL SELECTION:
   - Default: mixtral-8x7b (fast, cheap, good)
   - Need better reasoning: mistral-large or llama3-70b
   - Very simple tasks: llama3-8b
   - Test both if unsure!

5. PRODUCTION TIPS:
   - Use TRY_CAST for numeric conversions
   - Add error handling with CASE statements
   - Limit context length to control costs
   - Cache results to avoid re-processing
   - Monitor costs with query history

NEXT: Move to Worksheet 3 for Cortex Search and RAG patterns!
*/
