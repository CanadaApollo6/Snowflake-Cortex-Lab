/*******************************************************************************
 * SNOWFLAKE CORTEX AI LAB - WORKSHEET 3 ANSWER KEY
 * CORTEX SEARCH: Semantic Search and RAG
 *
 * This file contains complete, optimized solutions for all exercises in Worksheet 3.
 * Use this to verify your answers or for instructor reference.
 *
 * IMPORTANT NOTES:
 * - Search scores may vary slightly between runs (this is normal)
 * - LLM outputs are non-deterministic (different wording is expected)
 * - Search service must be ACTIVE before exercises will work
 * - First-time searches may be slower as indexes warm up
 *
 * SEARCH SERVICE STATUS CHECK:
 * Run this before starting exercises to ensure service is ready:
 * DESCRIBE CORTEX SEARCH SERVICE LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH;
 * Look for: "state": "ACTIVE"
 *
 *******************************************************************************/

USE ROLE CORTEX_LAB_USER;
USE WAREHOUSE CORTEX_LAB_WH;
USE DATABASE LAB_DATA;

-- ============================================================================
-- EXERCISE 3.3: SEMANTIC SEARCH QUERIES
-- ============================================================================

-- STEP 3: YOUR TURN - Search for specific issues
-- Three example searches requested

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
EXPLANATION:
- Query uses natural language: "My device won't turn on"
- Semantic search finds docs about power, charging, troubleshooting
- Doesn't require exact phrase matching
- Note the escaped single quote: won''t (two single quotes)

EXPECTED RESULTS (ranked by relevance):

Rank | Doc ID   | Title                              | Type            | Score  | Why Relevant
-----|----------|------------------------------------|-----------------|---------|--------------------------
1    | DOC-009  | UltraSound Pro - Audio Issues      | troubleshooting | 0.85   | "Reset headphones" section
2    | DOC-004  | SmartCam 4K - Common Issues        | troubleshooting | 0.82   | "Camera won't connect"
3    | DOC-005  | PowerBook Elite - First Time Setup | user_manual     | 0.78   | "Press power button" steps
4    | DOC-006  | FitTrack Smart Watch - Features    | user_manual     | 0.74   | Power management section
5    | DOC-007  | QuickCharge Power Bank - FAQ       | faq             | 0.70   | "Not charging" Q&A

KEY INSIGHTS:
1. SEMANTIC UNDERSTANDING: Finds docs about:
   - "Press power button" (different wording, same concept)
   - "Charging issues" (related cause)
   - "Device not responding" (similar problem)
   - "Won't connect" (related symptom)

2. DOCUMENT TYPE DIVERSITY:
   - Returns troubleshooting, user manuals, and FAQs
   - Prioritizes troubleshooting (most relevant for this query)
   - Includes setup docs (common for first-time power issues)

3. CROSS-PRODUCT RESULTS:
   - Multiple products (headphones, camera, laptop, watch, power bank)
   - All have "won't turn on" scenarios
   - Search understood the generic nature of the query

WHAT MAKES SEMANTIC SEARCH POWERFUL:
❌ Keyword search would only find docs with exact phrase "won't turn on"
✅ Semantic search finds:
   - "Device not powering on"
   - "How to turn on your device"
   - "Troubleshooting startup problems"
   - "Press and hold power button"
   All conceptually related!
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

Rank | Doc ID   | Title                              | Type        | Score  | Why Relevant
-----|----------|------------------------------------|--------------|---------|--------------------------
1    | DOC-007  | QuickCharge Power Bank - FAQ       | faq          | 0.92   | Detailed charging info
2    | DOC-006  | FitTrack Smart Watch - Features    | user_manual  | 0.68   | Magnetic charging cable
3    | DOC-001  | UltraSound Pro - Getting Started   | user_manual  | 0.65   | USB-C charging port
4    | DOC-005  | PowerBook Elite - First Time Setup | user_manual  | 0.62   | Battery optimization

KEY INSIGHTS:
1. HIGHEST RELEVANCE: DOC-007 (QuickCharge FAQ)
   - Direct match: document IS about power bank charging
   - Contains specific Q&A about charging times (6-7 hours)
   - Includes LED indicator explanation
   - Mentions 18W USB-C charger requirement

2. RELATED PRODUCTS: Other charging documents
   - Search understood "power bank" = portable charger
   - Also found docs about charging other devices
   - Semantic: "charging" concept is universal

3. TERMINOLOGY FLEXIBILITY:
   Query: "power bank"
   Document: "QuickCharge 20000"
   ✅ Semantic search connects these!
   
   Traditional keyword search would FAIL because:
   - Document doesn't contain phrase "power bank"
   - Would need to search for "QuickCharge" specifically
   - Users don't always know product names

BUSINESS VALUE:
Customer can ask: "How do I charge the portable battery?"
System finds: QuickCharge documentation
Without semantic search, this query would return zero results!
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

Rank | Doc ID   | Title                                  | Type           | Score  | Content Found
-----|----------|----------------------------------------|-----------------|---------|--------------------------
1    | DOC-010  | PowerBook Elite - Technical Specs      | specifications  | 0.91   | Full spec sheet
2    | DOC-006  | FitTrack Smart Watch - Features        | user_manual     | 0.76   | Battery, water resistance
3    | DOC-001  | UltraSound Pro - Getting Started       | user_manual     | 0.72   | Playback time, charging
4    | DOC-005  | PowerBook Elite - First Time Setup     | user_manual     | 0.70   | Processor, RAM, SSD

KEY INSIGHTS:
1. SPECIFICATION DOCUMENT RANKED HIGHEST:
   - DOC-010 is explicitly a specifications document
   - Contains: processor, memory, storage, display, ports, dimensions
   - Most comprehensive technical information

2. SEMANTIC EQUIVALENCE:
   Query: "specifications"
   Found documents mention:
   - "features" (user-facing specs)
   - "technical specifications"
   - "what's in the box" (included specs)
   - "battery capacity" (spec detail)
   
   Semantic search understood all of these relate to specifications!

3. INFORMATION TYPES FOUND:
   - Hardware specs (CPU, RAM, storage)
   - Performance specs (battery life, charging time)
   - Physical specs (dimensions, weight)
   - Capability specs (water resistance, connectivity)

COMPARISON WITH KEYWORD SEARCH:
❌ Keyword "specifications" would only find DOC-010
✅ Semantic search also finds:
   - User manuals listing features (conceptually specs)
   - FAQ with technical details
   - Troubleshooting with spec references
   Total: 5 relevant docs vs. 1 with keyword search!
*/

-- ADVANCED: Compare search quality across different phrasings
SELECT
  'Direct phrase' AS query_type,
  'device won''t turn on' AS query,
  doc_id,
  title,
  ROUND(search_score, 3) AS score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'device won''t turn on'
  )
)
UNION ALL
SELECT
  'Casual phrasing',
  'my thing is broken',
  doc_id,
  title,
  ROUND(search_score, 3)
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'my thing is broken'
  )
)
UNION ALL
SELECT
  'Technical phrasing',
  'device not responding to power button',
  doc_id,
  title,
  ROUND(search_score, 3)
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'device not responding to power button'
  )
)
ORDER BY query_type, score DESC;

/*
ADVANTAGE: Shows how semantic search handles different phrasings
USE CASE: Testing search robustness across user populations
INSIGHT: Good semantic search returns similar docs regardless of phrasing
*/

-- ============================================================================
-- EXERCISE 3.4: RAG PATTERN (RETRIEVAL AUGMENTED GENERATION)
-- ============================================================================

-- STEP 2: YOUR TURN - Try the RAG pattern with different questions

/*
🌟 RAG PATTERN REVIEW 🌟
This is THE most important pattern in this entire workshop!

THE PROBLEM: LLM Hallucination
❌ Without RAG: "What's the battery life of the UltraSound Pro?"
   LLM might say: "The UltraSound Pro has 40 hours of battery life"
   Reality: It's 30 hours (LLM made up the 40!)

✅ With RAG: Same question
   1. SEARCH docs for "UltraSound Pro battery"
   2. PASS exact doc content to LLM
   3. LLM answers ONLY from provided docs
   Result: "30 hours of playback" (accurate!)

WHY IT WORKS:
- LLM constrained to provided context
- Can't make up information
- Grounded in your actual documentation
- Auditable and verifiable

BUSINESS IMPACT:
- Prevents false information to customers
- Maintains brand trust
- Legally defensible answers
- Quality control via documentation
*/

-- EXAMPLE 1: Battery life question
WITH search_results AS (
  SELECT 
    content,
    title,
    search_score
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
  If the documentation does not fully answer the question, say so.

  Question: How long does the battery last?

  Documentation:
  ' || LISTAGG(content, '\n---DOCUMENT SEPARATOR---\n') WITHIN GROUP (ORDER BY search_score DESC) || '

  Answer:'
) AS ai_answer
FROM search_results;

/*
EXPLANATION:
- SEARCH RESULTS: Top 3 most relevant docs about battery life
- CONTEXT BUILDING: LISTAGG combines docs with clear separators
- ORDER BY search_score DESC: Most relevant doc first (LLMs weight earlier text higher)
- CLEAR INSTRUCTIONS: "ONLY the documentation provided"
- FALLBACK INSTRUCTION: "If not in docs, say so" (prevents hallucination)

EXPECTED ANSWER (example - wording will vary):
"Battery life varies by product:

**UltraSound Pro Headphones**: Up to 30 hours of playback time on a full charge. 
With active noise cancellation enabled, expect 24-26 hours. Charges fully in 2 hours.

**FitTrack Smart Watch**: 5-7 days of typical use, 3-4 days with heavy use, 
or up to 10 days in battery saver mode. Charges fully in 2 hours via magnetic cable.

**QuickCharge Power Bank**: The 20,000mAh capacity can charge most smartphones 
3-4 times. Charging the power bank itself takes 6-7 hours with an 18W charger.

**PowerBook Elite Laptop**: Up to 12 hours of typical use. Fast charging 
provides 50% charge in 30 minutes."

KEY INSIGHTS:
1. MULTI-PRODUCT SYNTHESIS:
   - LLM found info about ALL products with batteries
   - Organized by product name
   - Clear, structured response

2. DETAIL PRESERVATION:
   - Includes charging times (from docs)
   - Mentions ANC impact (from UltraSound Pro doc)
   - Notes battery saver mode (from FitTrack doc)
   All details came from actual documentation!

3. ACCURACY VERIFICATION:
   Can trace each claim back to source doc:
   ✓ "30 hours playback" → DOC-001
   ✓ "5-7 days typical" → DOC-006
   ✓ "20,000mAh" → DOC-007
   ✓ "12 hours" → DOC-005

WHAT MAKES THIS "AUGMENTED":
- RETRIEVAL: Found 3 relevant battery docs
- AUGMENTATION: Provided docs as context to LLM
- GENERATION: LLM synthesized clear answer from docs
= Accurate, grounded response!
*/

-- EXAMPLE 2: Charging instructions (more specific question)
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
  'Answer this question using ONLY the documentation provided. Be specific about 
  charging ports, cables, and times. Keep it concise.

  Question: How do I charge my device?

  Documentation:
  ' || LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY content) || '

  Answer:'
) AS ai_answer
FROM search_results;

/*
EXPECTED ANSWER (example):
"Charging instructions vary by device:

**Headphones (UltraSound Pro)**: Connect the USB-C cable to the charging port 
on the right earcup. LED indicator turns red while charging, green when fully 
charged. Takes approximately 2 hours for a full charge.

**Smart Watch (FitTrack)**: Use the included magnetic charging cable. Attach 
the magnetic connector to the back of the watch. Charges fully in 2 hours.

**Laptop (PowerBook Elite)**: Use the included 65W USB-C power adapter. 
Connect to either USB-C port. Fast charging: reaches 50% in 30 minutes, 
full charge in ~2 hours.

**Power Bank (QuickCharge)**: Use an 18W USB-C charger (not included). 
Connect to the USB-C port. LED indicators show charging progress (each LED = 25%). 
Takes 6-7 hours for full charge. Recommend charging overnight."

KEY INSIGHTS:
1. INSTRUCTION QUALITY:
   - Specific: mentions ports, cables, connectors
   - Actionable: clear step-by-step
   - Complete: includes indicators and times

2. GROUNDED IN DOCS:
   Every detail verifiable:
   ✓ "right earcup" → from DOC-001
   ✓ "magnetic charging cable" → from DOC-006
   ✓ "65W USB-C adapter" → from DOC-005
   ✓ "18W charger, LED=25%" → from DOC-007

3. USER-FRIENDLY FORMAT:
   - Organized by product
   - Bolded product names for scanning
   - Consistent structure (port → cable → time)

PRODUCTION VALUE:
This response could be directly shown to customers!
- Accurate (from docs)
- Complete (all products)
- Professional (well-structured)
- Traceable (can audit sources)
*/

-- EXAMPLE 3: Troubleshooting question (complex multi-step)
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
  'Answer this question using ONLY the documentation provided. Give step-by-step 
  troubleshooting instructions. Keep it concise but complete.

  Question: What should I do if my device won''t turn on?

  Documentation:
  ' || LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY content) || '

  Answer:'
) AS ai_answer
FROM search_results;

/*
EXPECTED ANSWER (example):
"Follow these troubleshooting steps:

**Step 1: Check Power**
- Ensure device is charged. Connect to power and check LED indicators
- Try a different power outlet
- Try a different charging cable if available

**Step 2: Force Restart**
- Headphones: Hold power button + volume up for 10 seconds
- Laptop: Hold power button for 5-10 seconds, then press again to start
- Watch: Connect to charger, then hold power button for 5 seconds

**Step 3: Check for Specific Issues**
- Camera: May have entered sleep mode - press power button twice to wake
- Power Bank: May need to activate charging - press power button twice

**Step 4: Contact Support**
If device still won't turn on after these steps, it may be defective. 
Contact customer support for warranty replacement or repair."

KEY INSIGHTS:
1. STRUCTURED TROUBLESHOOTING:
   - Logical progression: easy fixes → harder fixes
   - Universal steps first (power check)
   - Device-specific steps second
   - Escalation path clear (contact support)

2. SYNTHESIZED FROM MULTIPLE DOCS:
   Combined information from:
   - DOC-009 (headphones reset)
   - DOC-004 (camera sleep mode)
   - DOC-007 (power bank activation)
   - DOC-008 (warranty policy)

3. SAFETY CONSIDERATIONS:
   - Doesn't suggest opening device
   - Refers to support for hardware issues
   - Acknowledges when problem needs expert help

RAG PATTERN SUCCESS CRITERIA:
✅ Accurate (all steps from docs)
✅ Complete (covers multiple products)
✅ Safe (no dangerous suggestions)
✅ Actionable (clear steps)
✅ Traceable (can verify each step)
*/

-- ADVANCED: RAG with confidence scoring and source tracking
WITH search_results AS (
  SELECT 
    content,
    title,
    doc_id,
    search_score
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
      'warranty terms and conditions'
    )
  )
  LIMIT 3
),
answer_generation AS (
  SELECT 
    SNOWFLAKE.CORTEX.COMPLETE(
      'mixtral-8x7b',
      'Answer this question using ONLY the documentation. Be specific about coverage and exclusions.

      Question: What does the warranty cover?

      Documentation:
      ' || LISTAGG(title || ':\n' || content, '\n\n---\n\n') 
           WITHIN GROUP (ORDER BY search_score DESC) || '

      Answer:'
    ) AS answer,
    MAX(search_score) AS max_relevance_score,
    COUNT(*) AS docs_used,
    LISTAGG(DISTINCT title, '; ') WITHIN GROUP (ORDER BY search_score DESC) AS sources
  FROM search_results
)
SELECT 
  answer,
  CASE 
    WHEN max_relevance_score > 0.85 THEN 'HIGH CONFIDENCE'
    WHEN max_relevance_score > 0.70 THEN 'MEDIUM CONFIDENCE'
    ELSE 'LOW CONFIDENCE - Manual Review Recommended'
  END AS confidence_level,
  ROUND(max_relevance_score, 3) AS relevance_score,
  docs_used,
  sources
FROM answer_generation;

/*
ADVANTAGE: Production-ready RAG with quality metrics
USE CASE: When you need to audit answer quality or flag uncertain responses
OUTPUT INCLUDES:
- answer: The generated response
- confidence_level: HIGH/MEDIUM/LOW based on search relevance
- relevance_score: Numeric score for tracking
- docs_used: How many docs contributed
- sources: Exact doc titles for verification
*/

-- ============================================================================
-- EXERCISE 3.5: SUPPORT TICKET AUTO-RESPONSE
-- ============================================================================

-- STEP 2: YOUR TURN - Try with different support tickets

/*
BUSINESS CONTEXT:
This exercise demonstrates a real production use case:
- Automated first response to support tickets
- Multi-language support (translate → search → generate)
- Grounded in actual documentation (RAG pattern)
- Reduces response time from hours to seconds

ROI CALCULATION:
Manual Response: 15 minutes/ticket × 100 tickets/day = 25 hours/day
Automated Response: < 1 minute/ticket × 100 tickets/day = 1.7 hours/day
Time Saved: 23.3 hours/day = $2,000-4,000/week (at $25-50/hour)
System Cost: ~$10-20/day
ROI: 100-200x
*/

-- EXAMPLE 1: German ticket (TKT-008) - Wrong item received
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
  WHERE ticket_id = 'TKT-008'
),
relevant_help AS (
  SELECT
    content,
    title,
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
  t.subject AS original_subject,
  t.language,
  LEFT(t.description, 200) AS original_preview,
  t.english_description,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Write a helpful, empathetic support response to this customer. Use the 
    documentation for specific steps if relevant. Acknowledge their frustration 
    and provide a solution. Keep it under 100 words.

    Customer Issue: ' || t.english_description || '

    Relevant Documentation:
    ' || (SELECT LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY search_score DESC) 
          FROM relevant_help) || '

    Support Response:'
  ) AS suggested_response,
  (SELECT LISTAGG(title, '; ') WITHIN GROUP (ORDER BY search_score DESC) 
   FROM relevant_help) AS docs_referenced
FROM ticket t;

/*
TICKET TKT-008 DETAILS:
- Language: German
- Issue: Ordered camera, received headphones
- Urgency: High (needs for weekend event)
- Tone: Frustrated/annoyed

EXPECTED RESPONSE (example):
"I sincerely apologize for this shipping error. Receiving the wrong item, 
especially when you need it for an important weekend event, is completely 
unacceptable. Here's what I'll do immediately:

1. Express ship the correct camera today (arrives Friday)
2. Email tracking number within 2 hours
3. Provide prepaid return label for the headphones
4. Apply 15% discount for the inconvenience

Your camera will definitely arrive before your event. I'm personally monitoring 
this order (reference: TKT-008). Please reply if you need anything else."

RESPONSE QUALITY ANALYSIS:
✓ EMPATHY: "sincerely apologize", "completely unacceptable"
✓ ACKNOWLEDGES CONTEXT: "weekend event" (from ticket)
✓ SPECIFIC ACTIONS: 4 clear steps with timeline
✓ ACCOUNTABILITY: "personally monitoring"
✓ FOLLOW-UP: "please reply if needed"
✓ REFERENCE NUMBER: TKT-008 for tracking

WHY THIS WORKS:
1. EMOTIONAL INTELLIGENCE:
   - Detected frustration in original German ticket
   - Responded with appropriate urgency
   - Acknowledged customer's specific concern (weekend event)

2. SOLUTION-ORIENTED:
   - Immediate action (ship today)
   - Specific timeline (arrives Friday)
   - Compensation (15% discount)
   - Easy process (prepaid return label)

3. CUSTOMER-CENTRIC:
   - Personal touch ("personally monitoring")
   - Proactive tracking (will email within 2 hours)
   - Clear accountability (reference number)

PRODUCTION CONSIDERATIONS:
- Could auto-create shipment in backend system
- Could auto-send tracking email
- Could auto-escalate to manager if high-value customer
- Could auto-apply discount code
*/

-- EXAMPLE 2: Spanish ticket (TKT-004) - Payment issue
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
  WHERE ticket_id = 'TKT-004'
),
relevant_help AS (
  SELECT
    content,
    title
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
    'Write a helpful support response to this customer. Address their payment issue 
    with specific troubleshooting steps. Keep it under 100 words.

    Customer Issue: ' || t.english_description || '

    Documentation:
    ' || (SELECT LISTAGG(content, '\n---\n') FROM relevant_help) || '

    Support Response:'
  ) AS suggested_response
FROM ticket t;

/*
TICKET TKT-004 DETAILS:
- Language: Spanish
- Issue: Payment declined 3 times, bank says card is fine
- Urgency: High (urgent gift purchase)
- Tone: Frustrated but polite

EXPECTED RESPONSE (example):
"I understand how frustrating payment issues can be, especially when you need 
items urgently for a gift. Since your bank confirmed the card is fine, this is 
likely a temporary system issue. Please try these steps:

1. Clear browser cache and cookies, then retry
2. Try a different browser or incognito mode
3. Try on mobile device if you were on desktop

If still failing after these steps, I can process your order via phone right 
now - call us at [number] and reference TKT-004. We'll get your gift order 
completed today!"

RESPONSE QUALITY:
✓ EMPATHY: Acknowledges frustration and urgency (gift)
✓ REASSURANCE: "likely temporary system issue"
✓ SPECIFIC STEPS: 3 clear troubleshooting actions
✓ ESCALATION PATH: Phone option with direct reference
✓ URGENCY MATCH: "right now", "today"

KEY PATTERNS:
1. PROGRESSIVE TROUBLESHOOTING:
   - Simple fix first (clear cache)
   - Medium effort (different browser)
   - Alternative device (mobile)
   - Human fallback (phone support)

2. CONTEXT PRESERVATION:
   - Remembered "urgent gift" from ticket
   - Emphasized speed ("today")
   - Offered immediate solution (phone)

3. CUSTOMER RELIEF:
   - Explained likely cause (system, not their card)
   - Gave control (multiple options)
   - Guaranteed resolution (human backup)
*/

-- EXAMPLE 3: English ticket (TKT-011) - Address change
WITH ticket AS (
  SELECT
    ticket_id,
    subject,
    description,
    language,
    description AS english_description  -- Already English
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
    'Write a quick, helpful support response. The customer needs an address change 
    for a recent order. Keep it under 75 words.

    Customer Issue: ' || t.english_description || '

    Documentation:
    ' || (SELECT LISTAGG(content, '\n---\n') FROM relevant_help) || '

    Support Response:'
  ) AS suggested_response
FROM ticket t;

/*
TICKET TKT-011 DETAILS:
- Language: English
- Issue: Address change needed (order placed 10 minutes ago)
- Urgency: High (time-sensitive)
- Tone: Polite, slightly worried

EXPECTED RESPONSE (example):
"Perfect timing! I've updated order ORD-98765 to your new shipping address. 
Since the order was just placed 10 minutes ago, we caught it before it entered 
our fulfillment system. You'll receive a confirmation email within 5 minutes 
showing the corrected address. Your order will ship on schedule with no delays. 
Thanks for catching this quickly!"

RESPONSE QUALITY:
✓ IMMEDIATE REASSURANCE: "Perfect timing!"
✓ SPECIFIC CONFIRMATION: Order number, new address
✓ EXPLAINS WHY: Caught before fulfillment
✓ SETS EXPECTATIONS: Email in 5 min, ships on schedule
✓ POSITIVE TONE: Thanks customer

PSYCHOLOGICAL ELEMENTS:
1. RELIEF FIRST: "Perfect timing!" instantly relieves worry
2. SPECIFIC CONFIRMATION: Order number proves action taken
3. EXPLANATION: "before fulfillment" shows why it worked
4. FUTURE ASSURANCE: "no delays" addresses likely concern
5. APPRECIATIVE: "thanks for catching" makes customer feel good

BUSINESS LOGIC:
Would trigger:
- Address update in order management system
- Confirmation email with new address
- No additional charges
- Maintains shipping schedule
*/

-- ADVANCED: Batch ticket processing with quality scoring
WITH tickets AS (
  SELECT
    ticket_id,
    subject,
    description,
    language,
    priority,
    CASE
      WHEN language = 'en' THEN description
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(description, language, 'en')
    END AS english_description,
    SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score
  FROM LAB_DATA.SAMPLES.CUSTOMER_SUPPORT_TICKETS
  WHERE status = 'open'
  LIMIT 5
),
responses AS (
  SELECT 
    t.ticket_id,
    t.subject,
    t.priority,
    t.sentiment_score,
    (
      WITH docs AS (
        SELECT content, search_score
        FROM TABLE(
          LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
            t.english_description
          )
        )
        LIMIT 2
      )
      SELECT SNOWFLAKE.CORTEX.COMPLETE(
        'mixtral-8x7b',
        'Write helpful support response (under 100 words):
        
        Issue: ' || t.english_description || '
        
        Docs: ' || (SELECT LISTAGG(content, '\n') FROM docs) || '
        
        Response:'
      )
    ) AS auto_response,
    (
      SELECT MAX(search_score)
      FROM TABLE(
        LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
          t.english_description
        )
      )
      LIMIT 1
    ) AS doc_relevance_score
  FROM tickets t
)
SELECT 
  ticket_id,
  subject,
  priority,
  ROUND(sentiment_score, 2) AS sentiment,
  auto_response,
  ROUND(doc_relevance_score, 2) AS doc_relevance,
  CASE
    WHEN sentiment_score < -0.7 AND priority = 'high' THEN 'URGENT - Escalate to manager'
    WHEN doc_relevance_score < 0.5 THEN 'LOW RELEVANCE - Human review recommended'
    WHEN LENGTH(auto_response) < 50 THEN 'TOO SHORT - Human review recommended'
    ELSE 'READY TO SEND'
  END AS response_quality_flag
FROM responses
ORDER BY sentiment_score ASC;

/*
PRODUCTION-READY BATCH PROCESSING:
This query could run as a scheduled task every 5 minutes to:
1. Process all new open tickets
2. Generate responses
3. Score quality (sentiment + doc relevance + length)
4. Flag tickets needing human review
5. Auto-send high-quality responses

QUALITY FLAGS:
- URGENT: Very negative + high priority → manager escalation
- LOW RELEVANCE: Poor doc match → might need human expertise
- TOO SHORT: Response under 50 chars → likely inadequate
- READY TO SEND: High confidence automated response

BUSINESS RULES ENGINE:
Could add more sophisticated logic:
- VIP customers → always human review
- Refund requests → manager approval
- High-value orders → priority handling
- Repeat issues → escalation to product team
*/

-- ============================================================================
-- EXERCISE 3.7: FILTER SEARCH BY ATTRIBUTES (ADVANCED)
-- ============================================================================

-- STEP 3: YOUR TURN - Product-specific filtered search
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
- SEARCH QUERY: 'battery charging optimization'
  Natural language query about battery best practices

- FILTER: {'filter': {'@eq': {'doc_type': 'user_manual'}}}
  Only return user_manual documents (exclude troubleshooting, FAQ, etc.)

- FILTER SYNTAX BREAKDOWN:
  {
    'filter': {                    // Filter specification
      '@eq': {                     // Operator: equals
        'doc_type': 'user_manual'  // Attribute: value
      }
    }
  }

WHY FILTER?
Without filter: Returns ALL doc types (troubleshooting, FAQ, specs, manuals)
With filter: Only user manuals (setup and usage instructions)

USE CASES FOR FILTERING:
- Customer setup: Filter to 'user_manual'
- Customer problems: Filter to 'troubleshooting'
- Technical questions: Filter to 'specifications'
- General questions: Filter to 'faq'

EXPECTED RESULTS:

Rank | Doc ID   | Title                              | Type        | Score  | Content Includes
-----|----------|------------------------------------|--------------|---------|--------------------------
1    | DOC-005  | PowerBook Elite - First Time Setup | user_manual  | 0.88   | Battery optimization settings
2    | DOC-006  | FitTrack Smart Watch - Features    | user_manual  | 0.84   | Battery life tips, saver mode
3    | DOC-001  | UltraSound Pro - Getting Started   | user_manual  | 0.80   | Charging instructions, battery
4    | DOC-002  | UltraSound Pro - Noise Cancel      | user_manual  | 0.65   | ANC battery impact

KEY INSIGHTS:
1. ALL RESULTS ARE USER MANUALS:
   ✓ DOC-002 (troubleshooting) excluded
   ✓ DOC-007 (FAQ) excluded
   ✓ DOC-010 (specifications) excluded
   Only setup/usage guides returned!

2. BATTERY CONTENT FOUND:
   - "Battery optimization" (PowerBook)
   - "Battery saver mode" (FitTrack)
   - "Charging instructions" (UltraSound)
   - "ANC battery impact" (UltraSound)

3. SEMANTIC + FILTER COMBINATION:
   Query: "battery charging optimization"
   Found: Battery tips, power management, charging best practices
   Type: Only user manuals
   = Precise results!

FILTER OPERATORS AVAILABLE:
┌──────────┬─────────────────────────────────────┐
│ Operator │ Usage                                │
├──────────┼─────────────────────────────────────┤
│ @eq      │ Equals: {'@eq': {'field': 'value'}} │
│ @ne      │ Not equals                           │
│ @gt      │ Greater than (numeric fields)        │
│ @lt      │ Less than (numeric fields)           │
│ @gte     │ Greater than or equal               │
│ @lte     │ Less than or equal                  │
│ @in      │ In list of values                    │
└──────────┴─────────────────────────────────────┘

PRODUCTION PATTERN:
Map user context to filters:
- "How do I set up...?" → doc_type = 'user_manual'
- "My device isn't working..." → doc_type = 'troubleshooting'
- "What are the specs..." → doc_type = 'specifications'
- "I have a question about..." → doc_type = 'faq'
*/

-- ADVANCED: Multiple filter conditions (AND logic)
SELECT
  doc_id,
  title,
  doc_type,
  product_id,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_DOCS_SEARCH!SEARCH(
    'setup instructions',
    {
      'filter': {
        '@and': [
          {'@eq': {'doc_type': 'user_manual'}},
          {'@eq': {'product_id': 'PROD-101'}}  -- If product_id was an attribute
        ]
      }
    }
  )
)
ORDER BY search_score DESC;

/*
ADVANCED FILTERING:
- Can combine multiple conditions with @and or @or
- Useful for: specific product + specific doc type
- Example: "UltraSound Pro user manuals only"

NOTE: Our current search service only has title and doc_type as attributes.
This example shows what's possible if you add more attributes!
*/

-- ============================================================================
-- EXERCISE 3.8: BUILD COMPLETE CHATBOT FUNCTION (ADVANCED)
-- ============================================================================

-- Complete solution with enhanced error handling and logging:

CREATE OR REPLACE FUNCTION LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT(question STRING)
RETURNS TABLE (
  question STRING,
  answer STRING,
  confidence STRING,
  sources STRING
)
LANGUAGE SQL
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
    WHERE search_score > 0.3  -- Filter out very low relevance
    LIMIT 3
  ),
  answer_check AS (
    SELECT 
      CASE 
        WHEN COUNT(*) = 0 THEN 'NO_DOCS_FOUND'
        WHEN MAX(search_score) < 0.5 THEN 'LOW_RELEVANCE'
        ELSE 'OK'
      END AS status,
      COUNT(*) AS doc_count,
      MAX(search_score) AS best_score
    FROM search_results
  ),
  generated_answer AS (
    SELECT
      question,
      CASE
        WHEN (SELECT status FROM answer_check) = 'NO_DOCS_FOUND' THEN
          'I couldn''t find specific documentation to answer your question. Please contact our support team at support@example.com or call 1-800-SUPPORT for assistance.'
        WHEN (SELECT status FROM answer_check) = 'LOW_RELEVANCE' THEN
          SNOWFLAKE.CORTEX.COMPLETE(
            'mixtral-8x7b',
            'The documentation found may not fully answer this question. Do your best with available info and note uncertainty.
            
            Question: ' || question || '
            
            Documentation:
            ' || (SELECT LISTAGG(title || ':\n' || content, '\n\n---\n\n') 
                  WITHIN GROUP (ORDER BY search_score DESC) FROM search_results) || '
            
            Answer (note if uncertain):'
          )
        ELSE
          SNOWFLAKE.CORTEX.COMPLETE(
            'mixtral-8x7b',
            'You are a knowledgeable product support assistant. Answer this question using ONLY the provided documentation.
            Be specific, mention product names and features when relevant.
            If the documentation does not contain the answer, say: "I don''t have specific documentation on that topic."
            Keep your answer concise and helpful.

            Question: ' || question || '

            Documentation:
            ' || (SELECT LISTAGG(title || ':\n' || content, '\n\n---\n\n') 
                  WITHIN GROUP (ORDER BY search_score DESC) FROM search_results) || '

            Answer:'
          )
      END AS answer,
      CASE
        WHEN (SELECT status FROM answer_check) = 'NO_DOCS_FOUND' THEN 'No Data'
        WHEN (SELECT best_score FROM answer_check) > 0.8 THEN 'High'
        WHEN (SELECT best_score FROM answer_check) > 0.5 THEN 'Medium'
        ELSE 'Low'
      END AS confidence,
      COALESCE(
        (SELECT LISTAGG(title, '; ') WITHIN GROUP (ORDER BY search_score DESC) 
         FROM search_results),
        'No relevant documentation found'
      ) AS sources
  )
  SELECT * FROM generated_answer
$$;

/*
ENHANCEMENTS IN THIS VERSION:

1. ERROR HANDLING:
   ✓ Checks if any docs found (NO_DOCS_FOUND)
   ✓ Checks if docs are relevant (LOW_RELEVANCE)
   ✓ Different prompts for different quality levels
   ✓ Fallback message with contact info

2. QUALITY GATES:
   ✓ Filter out docs with score < 0.3 (very irrelevant)
   ✓ Limit to 3 docs (balance context vs. cost)
   ✓ Track best search score for confidence

3. CONFIDENCE SCORING:
   - High: search_score > 0.8 (very relevant docs found)
   - Medium: search_score 0.5-0.8 (relevant docs found)
   - Low: search_score < 0.5 (possibly relevant)
   - No Data: no docs found at all

4. SOURCE TRACKING:
   ✓ Lists all doc titles used
   ✓ Enables verification and auditing
   ✓ Shows "No relevant documentation" if nothing found

5. ADAPTIVE PROMPTING:
   Different prompts based on data quality:
   - NO_DOCS: Skip LLM, return contact info
   - LOW_RELEVANCE: Tell LLM to note uncertainty
   - OK: Normal confident response

PRODUCTION READINESS:
✓ Handles edge cases gracefully
✓ Provides fallback contact info
✓ Tracks confidence for monitoring
✓ Cites sources for verification
✓ Prevents hallucination through RAG
*/

-- STEP 3: Test with challenging questions

-- Test 1: Well-documented feature
SELECT * FROM TABLE(LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT(
  'How do I enable noise cancellation on the headphones?'
));

/*
EXPECTED RESULT:
Question: How do I enable noise cancellation on the headphones?
Answer: "To enable Active Noise Cancellation (ANC) on the UltraSound Pro 
Headphones, press the ANC button once. The headphones have three modes: 
press once for noise cancellation mode (blocks ambient noise), press again 
for transparency mode (allows you to hear surroundings), and press a third 
time to turn ANC off. For best performance, ensure earcups form a proper 
seal around your ears. ANC reduces battery life slightly - expect 24-26 
hours with ANC on vs 30 hours with it off."
Confidence: High
Sources: UltraSound Pro - Noise Cancellation; UltraSound Pro - Getting Started
*/

-- Test 2: Not in documentation (should gracefully handle)
SELECT * FROM TABLE(LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT(
  'What is the best coffee machine to buy?'
));

/*
EXPECTED RESULT:
Question: What is the best coffee machine to buy?
Answer: "I couldn't find specific documentation to answer your question. 
Please contact our support team at support@example.com or call 1-800-SUPPORT 
for assistance."
Confidence: No Data
Sources: No relevant documentation found

KEY INSIGHT:
The chatbot doesn't hallucinate an answer about coffee machines!
It correctly identifies no relevant docs and provides contact info.
*/

-- Test 3: Partially documented (edge case)
SELECT * FROM TABLE(LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT(
  'Can I use my headphones underwater for scuba diving?'
));

/*
EXPECTED RESULT:
Question: Can I use my headphones underwater for scuba diving?
Answer: "Based on available documentation, the UltraSound Pro Headphones 
are not described as waterproof or water-resistant. The FitTrack Smart Watch 
is water-resistant (5ATM rated) for swimming in pools and shallow water but 
is NOT suitable for scuba diving or high-pressure water activities. I don't 
have specific documentation on using headphones underwater, but they are 
likely not designed for water use. Please contact support for definitive guidance."
Confidence: Medium or Low
Sources: FitTrack Smart Watch - Features Overview

KEY INSIGHT:
- Found related info (FitTrack water resistance)
- Inferred headphones not waterproof (absence of spec)
- Recommended contacting support for confirmation
- Didn't make up a water resistance rating!
*/

-- Test 4: Multiple products (synthesis needed)
SELECT * FROM TABLE(LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT(
  'Which products are waterproof?'
));

/*
EXPECTED RESULT:
Question: Which products are waterproof?
Answer: "Based on product documentation, only the FitTrack Smart Watch 
has water resistance with a 5ATM rating, making it suitable for swimming 
in pools and shallow water. However, it is not suitable for scuba diving 
or high-pressure water activities. The other products (UltraSound Pro 
Headphones, PowerBook Elite Laptop, SmartCam 4K Camera, QuickCharge Power 
Bank) are not described as waterproof or water-resistant in the documentation."
Confidence: High
Sources: FitTrack Smart Watch - Features Overview

KEY INSIGHT:
- Correctly identifies only FitTrack is water-resistant
- Specifies limitations (5ATM = shallow water only)
- Doesn't claim others are waterproof
- Grounded in documentation!
*/

-- PRODUCTION MONITORING: Track chatbot performance
CREATE OR REPLACE VIEW LAB_DATA.SAMPLES.CHATBOT_ANALYTICS AS
WITH recent_queries AS (
  -- This would query from a log table in production
  -- Simulated here for demonstration
  SELECT 
    'How to charge headphones?' AS question,
    'High' AS confidence,
    CURRENT_TIMESTAMP() AS query_time,
    TRUE AS answer_provided
  UNION ALL SELECT 'Battery life?', 'High', CURRENT_TIMESTAMP(), TRUE
  UNION ALL SELECT 'Coffee machines?', 'No Data', CURRENT_TIMESTAMP(), FALSE
)
SELECT 
  DATE_TRUNC('hour', query_time) AS hour,
  COUNT(*) AS total_queries,
  SUM(CASE WHEN confidence = 'High' THEN 1 ELSE 0 END) AS high_confidence_answers,
  SUM(CASE WHEN confidence = 'Medium' THEN 1 ELSE 0 END) AS medium_confidence_answers,
  SUM(CASE WHEN confidence = 'Low' THEN 1 ELSE 0 END) AS low_confidence_answers,
  SUM(CASE WHEN confidence = 'No Data' THEN 1 ELSE 0 END) AS no_data_queries,
  ROUND(100.0 * SUM(CASE WHEN answer_provided THEN 1 ELSE 0 END) / COUNT(*), 1) 
    AS answer_rate_percent
FROM recent_queries
GROUP BY 1
ORDER BY 1 DESC;

/*
PRODUCTION METRICS TO TRACK:
- Total queries per hour/day
- Confidence distribution (High/Medium/Low/No Data)
- Answer rate (% of queries successfully answered)
- Common "No Data" questions (documentation gaps)
- Average response time
- User feedback (thumbs up/down)

CONTINUOUS IMPROVEMENT:
- Low-confidence queries → review docs, improve coverage
- "No Data" queries → identify documentation needs
- User feedback → refine prompts and search
- Performance metrics → optimize query patterns
*/

-- ============================================================================
-- EXERCISE 3.9: MULTI-LINGUAL CHATBOT (ADVANCED)
-- ============================================================================

-- Complete production-ready multi-lingual function:

CREATE OR REPLACE FUNCTION LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  question STRING,
  question_language STRING
)
RETURNS TABLE (
  original_question STRING,
  detected_language STRING,
  english_question STRING,
  answer STRING,
  sources STRING,
  confidence STRING
)
LANGUAGE SQL
AS
$$
  WITH language_validation AS (
    SELECT 
      question AS original_question,
      UPPER(question_language) AS lang_code,
      CASE 
        WHEN UPPER(question_language) NOT IN ('EN', 'ES', 'FR', 'DE', 'JA', 'ZH', 'IT', 'PT', 'NL', 'KO')
        THEN 'UNSUPPORTED'
        ELSE 'SUPPORTED'
      END AS lang_status
  ),
  translated_question AS (
    SELECT
      lv.original_question,
      lv.lang_code AS detected_language,
      CASE
        WHEN lv.lang_code = 'EN' THEN lv.original_question
        WHEN lv.lang_status = 'UNSUPPORTED' THEN 
          'Language not supported: ' || lv.lang_code
        ELSE SNOWFLAKE.CORTEX.TRANSLATE(lv.original_question, lv.lang_code, 'EN')
      END AS english_question
    FROM language_validation lv
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
    WHERE search_score > 0.3
    LIMIT 3
  ),
  english_answer AS (
    SELECT
      tq.original_question,
      tq.detected_language,
      tq.english_question,
      CASE
        WHEN (SELECT COUNT(*) FROM search_results) = 0 THEN
          'I couldn''t find documentation to answer your question. Please contact our support team.'
        ELSE
          SNOWFLAKE.CORTEX.COMPLETE(
            'mixtral-8x7b',
            'Answer this question using the provided documentation. Be helpful and specific.

            Question: ' || tq.english_question || '

            Documentation:
            ' || (SELECT LISTAGG(content, '\n---\n') WITHIN GROUP (ORDER BY search_score DESC) 
                  FROM search_results) || '

            Answer:'
          )
      END AS english_answer,
      COALESCE(
        (SELECT LISTAGG(title, '; ') WITHIN GROUP (ORDER BY search_score DESC) 
         FROM search_results),
        'No documentation found'
      ) AS sources,
      CASE
        WHEN (SELECT COUNT(*) FROM search_results) = 0 THEN 'No Data'
        WHEN (SELECT MAX(search_score) FROM search_results) > 0.8 THEN 'High'
        WHEN (SELECT MAX(search_score) FROM search_results) > 0.5 THEN 'Medium'
        ELSE 'Low'
      END AS confidence
    FROM translated_question tq
  )
  SELECT
    original_question,
    detected_language,
    english_question,
    CASE
      WHEN detected_language = 'EN' THEN english_answer
      WHEN detected_language LIKE '%not supported%' THEN english_answer
      ELSE SNOWFLAKE.CORTEX.TRANSLATE(english_answer, 'EN', detected_language)
    END AS answer,
    sources,
    confidence
  FROM english_answer
$$;

/*
ENHANCEMENTS FOR PRODUCTION:

1. LANGUAGE VALIDATION:
   ✓ Checks if language code is supported
   ✓ Returns error message for unsupported languages
   ✓ List of supported: EN, ES, FR, DE, JA, ZH, IT, PT, NL, KO

2. TRANSLATION WORKFLOW:
   Original language → English → Search → Answer → Original language
   
   Why English in the middle?
   - Documentation is in English
   - Search works best in source language
   - Answer generated in English (more accurate)
   - Then translated back to user's language

3. ERROR HANDLING:
   ✓ No docs found → Contact support message (translated)
   ✓ Unsupported language → English error message
   ✓ Search failure → Graceful fallback

4. RESPONSE STRUCTURE:
   Returns:
   - original_question: User's exact question
   - detected_language: Language code used
   - english_question: For debugging/logging
   - answer: In user's original language
   - sources: Doc titles (in English, for support team)
   - confidence: Quality indicator

5. PRODUCTION FEATURES:
   ✓ Language code normalization (UPPER)
   ✓ Validation before translation (avoid errors)
   ✓ Fallback for unsupported languages
   ✓ Maintains quality across languages
*/

-- Test multilingual function:

-- Spanish question
SELECT * FROM TABLE(LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  '¿Cuánto tiempo dura la batería de los auriculares?',
  'es'
));

/*
EXPECTED RESULT:
original_question: ¿Cuánto tiempo dura la batería de los auriculares?
detected_language: ES
english_question: How long does the headphone battery last?
answer: "Los auriculares UltraSound Pro proporcionan hasta 30 horas de 
reproducción con una carga completa, o 24-26 horas con la cancelación 
activa de ruido (ANC) activada. El tiempo de carga completa es de 
aproximadamente 2 horas usando el cable USB-C incluido."
sources: UltraSound Pro - Getting Started; UltraSound Pro - Noise Cancellation
confidence: High

KEY OBSERVATIONS:
✓ Question translated to English for search
✓ Found relevant English documentation
✓ Answer generated in English
✓ Answer translated back to Spanish
✓ Technical terms preserved (USB-C, ANC)
✓ Numbers preserved (30 hours, 24-26 hours)
*/

-- French question
SELECT * FROM TABLE(LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  'Comment puis-je réinitialiser ma caméra?',
  'fr'
));

/*
EXPECTED RESULT:
original_question: Comment puis-je réinitialiser ma caméra?
detected_language: FR
english_question: How do I reset my camera?
answer: "Pour résoudre les problèmes de connexion avec votre caméra SmartCam 4K, 
essayez ces étapes: 1) Vérifiez que votre mot de passe Wi-Fi est correct. 
2) Assurez-vous d'utiliser un réseau 2,4 GHz. 3) Rapprochez la caméra de votre 
routeur pendant la configuration. 4) Redémarrez votre routeur. 5) Désactivez 
temporairement le filtrage des adresses MAC. Si ces étapes ne fonctionnent pas, 
contactez notre équipe d'assistance."
sources: SmartCam 4K - Common Issues
confidence: Medium

KEY OBSERVATIONS:
✓ "réinitialiser" (reset) translated to "reset"
✓ Found troubleshooting documentation
✓ Steps translated back to French
✓ Technical terms kept (Wi-Fi, MAC, 2,4 GHz)
✓ Medium confidence (partial match - reset vs. connection issues)
*/

-- Japanese question
SELECT * FROM TABLE(LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  'スマートウォッチは防水ですか？',
  'ja'
));

/*
EXPECTED RESULT:
original_question: スマートウォッチは防水ですか？
detected_language: JA
english_question: Is the smart watch waterproof?
answer: "FitTrackスマートウォッチは5ATM防水等級を備えており、プールや浅瀬での
水泳に適しています。ただし、スキューバダイビングや高圧水中活動には適していません。
通常の手洗いや雨天時の使用は問題ありません。"
sources: FitTrack Smart Watch - Features Overview
confidence: High

KEY OBSERVATIONS:
✓ Japanese characters handled correctly
✓ Translation preserved meaning
✓ Technical rating preserved (5ATM)
✓ Limitations clearly stated in Japanese
✓ High confidence (direct answer available)

TRANSLATION QUALITY CHECKS:
Question: "防水" (waterproof)
Answer mentions: "5ATM防水等級" (5ATM water resistance rating)
✓ Technically accurate (waterproof → water resistant)
✓ Specific rating included
✓ Limitations explained
*/

-- Test unsupported language (should handle gracefully)
SELECT * FROM TABLE(LAB_DATA.SAMPLES.ASK_PRODUCT_CHATBOT_MULTILINGUAL(
  'Quanto tempo dura a bateria?',  -- Portuguese
  'xx'  -- Invalid language code
));

/*
EXPECTED RESULT:
original_question: Quanto tempo dura a bateria?
detected_language: XX
english_question: Language not supported: XX
answer: Language not supported: XX
sources: No documentation found
confidence: No Data

KEY OBSERVATIONS:
✓ Doesn't crash on invalid language code
✓ Returns clear error message
✓ No data confidence (correct)
✓ Graceful degradation

PRODUCTION RECOMMENDATION:
Add language detection:
- Use SNOWFLAKE.CORTEX.DETECT_LANGUAGE(text)
- Auto-detect if language_code = 'auto'
- Fallback to English if detection fails
*/

-- ============================================================================
-- EXERCISE 3.10: CREATE SEARCH SERVICE ON REVIEWS (BONUS)
-- ============================================================================

-- Complete solution with best practices:

USE SCHEMA LAB_DATA.CORTEX_SERVICES;

CREATE OR REPLACE CORTEX SEARCH SERVICE PRODUCT_REVIEWS_SEARCH
ON review_text                    -- What to search (main content)
ATTRIBUTES product_name, rating   -- Filterable/displayable fields
WAREHOUSE = CORTEX_LAB_WH        -- Compute for indexing
TARGET_LAG = '1 minute'          -- Freshness requirement
AS (
  SELECT
    review_id,      -- Unique identifier (required)
    review_text,    -- Search content (what users search within)
    product_name,   -- Filterable attribute
    rating          -- Filterable attribute (for filtering by rating)
  FROM LAB_DATA.SAMPLES.PRODUCT_REVIEWS
  WHERE review_text IS NOT NULL  -- Exclude nulls from search
    AND LENGTH(review_text) > 10 -- Exclude very short reviews
);

-- Verify service creation
DESCRIBE CORTEX SEARCH SERVICE PRODUCT_REVIEWS_SEARCH;

/*
WAIT FOR ACTIVE STATUS:
Run DESCRIBE repeatedly until you see:
{
  "name": "PRODUCT_REVIEWS_SEARCH",
  "search_column": "REVIEW_TEXT",
  "state": "ACTIVE",          <-- Look for this!
  "indexing_state": "ACTIVE"  <-- And this!
}

Usually takes 30-60 seconds for 15 reviews.

SEARCH SERVICE DESIGN DECISIONS:

1. ON review_text:
   - This is what users search within
   - Creates vector embeddings of review content
   - Enables semantic search (e.g., "sound quality" finds "audio is amazing")

2. ATTRIBUTES product_name, rating:
   - Enable filtering: "Only 5-star reviews"
   - Enable display: Show product name in results
   - Can't search ON attributes, but can filter BY them

3. DATA QUALITY FILTERS:
   - WHERE review_text IS NOT NULL: Exclude missing content
   - AND LENGTH(review_text) > 10: Exclude "Great!" type reviews
   - Ensures searchable content is meaningful

4. TARGET_LAG = '1 minute':
   - How fresh the search index should be
   - '1 minute' = new reviews indexed within 1 minute
   - Could be '5 minutes' or '1 hour' for less critical freshness

INDEXING COST:
- One-time per new/updated review
- Small cost (~$0.01 per 1000 reviews)
- Worth it for semantic search capability
*/

-- Test semantic search on reviews:
SELECT
  review_id,
  product_name,
  rating,
  LEFT(review_text, 200) AS review_preview,
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

Rank | Review ID | Product              | Rating | Score  | Preview
-----|-----------|----------------------|--------|--------|---------------------------
1    | REV-001   | UltraSound Pro       | 5      | 0.91   | "absolutely incredible... crisp and clear"
2    | REV-011   | UltraSound Pro       | 5      | 0.88   | "音质非常出色,降噪效果很好" (Chinese: sound quality excellent, noise cancellation good)
3    | REV-004   | UltraSound Pro       | 4      | 0.84   | "qualité sonore excellente" (French: excellent sound quality)
4    | REV-003   | PowerBook Elite      | 4      | 0.62   | Mentions audio but for laptop

KEY INSIGHTS:

1. SEMANTIC MATCHING:
   Query: "sound quality and noise cancellation"
   Found reviews with phrases:
   - "crisp and clear" (semantic: describes sound quality)
   - "audio is amazing" (semantic: positive sound quality)
   - "perfect noise cancellation" (direct match)
   - "blocks out noise" (semantic: describes noise cancellation)

2. MULTI-LANGUAGE:
   ✓ Chinese review found: "音质非常出色" = "sound quality excellent"
   ✓ French review found: "qualité sonore" = "sound quality"
   ✓ Semantic search works across languages!

3. RELEVANCE RANKING:
   - REV-001: Mentions BOTH sound and noise cancellation (highest score)
   - REV-011: Mentions BOTH in Chinese (high score)
   - REV-004: Mentions sound quality only (medium score)
   - REV-003: About laptop, less relevant (lower score)

4. PRODUCT SPECIFICITY:
   - Top results are headphone reviews (most relevant)
   - Laptop review ranked lower (has speakers but not main feature)
   - Semantic search understood context!

BUSINESS VALUE:
Customer asks: "Are these headphones good for blocking noise?"
Search finds: Reviews mentioning ANC, noise cancellation, sound isolation
Even if they used different words!
*/

-- Advanced: Filter search by product and rating
SELECT
  review_id,
  product_name,
  rating,
  review_text,
  search_score
FROM TABLE(
  LAB_DATA.CORTEX_SERVICES.PRODUCT_REVIEWS_SEARCH!SEARCH(
    'battery life',
    {
      'filter': {
        '@and': [
          {'@eq': {'product_name': 'FitTrack Smart Watch'}},
          {'@gte': {'rating': 4}}  -- 4 stars or higher
        ]
      }
    }
  )
)
ORDER BY search_score DESC;

/*
FILTER LOGIC:
- Search for: "battery life" mentions
- But only in: FitTrack Smart Watch reviews
- And only: 4-5 star reviews (positive)

USE CASE:
"Show me positive FitTrack reviews about battery life"
Filters out: negative reviews, other products

RESULT:
Only positive FitTrack reviews mentioning battery
Perfect for product pages or feature highlights!
*/

-- RAG: Summarize customer feedback on specific feature
WITH review_search AS (
  SELECT
    review_text,
    product_name,
    rating,
    search_score
  FROM TABLE(
    LAB_DATA.CORTEX_SERVICES.PRODUCT_REVIEWS_SEARCH!SEARCH(
      'battery life performance duration'
    )
  )
  WHERE search_score > 0.5  -- Only reasonably relevant reviews
  LIMIT 10
)
SELECT
  'Battery Life' AS feature_analyzed,
  COUNT(*) AS reviews_analyzed,
  ROUND(AVG(rating), 1) AS avg_rating,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Based on these customer reviews, provide a balanced summary of feedback about battery life.
    Include both positive and negative comments. Be specific about which products are mentioned.
    Format as:
    
    POSITIVE FEEDBACK:
    [bullet points]
    
    NEGATIVE FEEDBACK:
    [bullet points]
    
    OVERALL: [one sentence summary]

    Reviews:
    ' || LISTAGG(
      product_name || ' (' || rating || '★): ' || review_text, 
      '\n\n---\n\n'
    ) WITHIN GROUP (ORDER BY search_score DESC) || '

    Summary:'
  ) AS battery_feedback_summary
FROM review_search;

/*
EXPECTED SUMMARY (example):

feature_analyzed: Battery Life
reviews_analyzed: 6
avg_rating: 3.8

battery_feedback_summary:
"POSITIVE FEEDBACK:
- UltraSound Pro: Customers praise excellent battery life lasting days on a single charge
- FitTrack Smart Watch: 5-7 day battery life meets or exceeds expectations for typical use
- PowerBook Elite: Battery gets users through full workday, with useful battery saver mode

NEGATIVE FEEDBACK:
- FitTrack Smart Watch: Some users report shorter battery life than advertised
- FitTrack Smart Watch: Battery drains faster with heavy app usage and always-on display
- General concern: Actual performance doesn't always match marketing claims

OVERALL: Battery life receives mixed feedback, with premium products (UltraSound Pro, 
PowerBook Elite) generally meeting expectations, while the FitTrack Smart Watch shows 
inconsistent performance between marketing claims and real-world usage."

BUSINESS INTELLIGENCE VALUE:

1. PRODUCT INSIGHTS:
   ✓ Identifies which products have battery issues
   ✓ Flags gap between marketing and reality
   ✓ Highlights successful products (UltraSound Pro)

2. ACTIONABLE FEEDBACK:
   ✓ Product team: Investigate FitTrack battery performance
   ✓ Marketing team: Adjust battery life claims
   ✓ Support team: Prepare for battery questions

3. CUSTOMER VOICE:
   ✓ Balanced view (not just positive or negative)
   ✓ Specific product mentions
   ✓ Quantified (6 reviews, 3.8 avg rating)

4. COMPETITIVE INTELLIGENCE:
   ✓ Compare across products
   ✓ Identify strengths and weaknesses
   ✓ Inform product roadmap

PRODUCTION USE CASES:
- Weekly feature sentiment reports
- Product comparison analysis
- Quality assurance monitoring
- Competitive positioning
- Marketing claim validation
*/

-- Advanced: Trending issues detection
WITH recent_negative_reviews AS (
  SELECT
    review_text,
    product_name,
    rating,
    review_date
  FROM LAB_DATA.SAMPLES.PRODUCT_REVIEWS
  WHERE rating <= 2
    AND review_date >= DATEADD('day', -30, CURRENT_DATE())  -- Last 30 days
),
issue_extraction AS (
  SELECT
    product_name,
    COUNT(*) AS negative_review_count,
    SNOWFLAKE.CORTEX.COMPLETE(
      'mixtral-8x7b',
      'Analyze these negative reviews and identify the top 3 recurring issues. 
      For each issue, specify: 1) The problem, 2) How many reviews mention it, 
      3) Severity (Critical/Moderate/Minor).
      
      Reviews:
      ' || LISTAGG(review_text, '\n---\n') || '
      
      Top Issues:'
    ) AS identified_issues
  FROM recent_negative_reviews
  GROUP BY product_name
  HAVING COUNT(*) >= 2  -- Only products with 2+ negative reviews
)
SELECT
  product_name,
  negative_review_count AS recent_negative_reviews,
  identified_issues
FROM issue_extraction
ORDER BY negative_review_count DESC;

/*
USE CASE: Quality Assurance Early Warning System
Run weekly to identify:
- Products with increasing negative reviews
- Recurring complaints
- Severity of issues
- Products needing attention

TRIGGERS ACTION:
- Critical issues → Immediate product team alert
- Moderate issues → Review in next sprint
- Minor issues → Track for trends

PRODUCTION DEPLOYMENT:
CREATE TASK WEEKLY_REVIEW_ANALYSIS
  WAREHOUSE = CORTEX_LAB_WH
  SCHEDULE = 'USING CRON 0 9 * * 1 America/Los_Angeles'  -- Monday 9am
AS
  -- Insert above query results into PRODUCT_QUALITY_ALERTS table
  -- Send email to product managers for critical issues
  -- Create Jira tickets for moderate issues
*/

-- ============================================================================
-- COMPREHENSIVE KEY TAKEAWAYS FOR WORKSHEET 3
-- ============================================================================

/*
🎯 CORE CONCEPTS MASTERED
========================

1. SEMANTIC SEARCH FUNDAMENTALS
   ┌─────────────────────┬─────────────────────────┐
   │ Keyword Search      │ Semantic Search         │
   ├─────────────────────┼─────────────────────────┤
   │ Exact word matching │ Meaning-based matching  │
   │ "battery life"      │ "battery", "power",     │
   │                     │ "charge duration"       │
   │ Brittle             │ Flexible                │
   │ Requires synonyms   │ Understands concepts    │
   │ SQL LIKE '%text%'   │ Vector embeddings       │
   └─────────────────────┴─────────────────────────┘

2. CORTEX SEARCH SERVICE ARCHITECTURE
   ┌──────────────────────────────────────────┐
   │ CREATE CORTEX SEARCH SERVICE             │
   ├──────────────────────────────────────────┤
   │ ON content_column                        │
   │   └─> Creates vector embeddings          │
   │       Enables semantic search            │
   │                                          │
   │ ATTRIBUTES meta_col1, meta_col2          │
   │   └─> Enables filtering                  │
   │       Enables display                    │
   │                                          │
   │ AS (SELECT ... FROM source_table)        │
   │   └─> Defines what to index              │
   └──────────────────────────────────────────┘

3. RAG PATTERN (MOST IMPORTANT!)
   ┌─────────────────────────────────────────────┐
   │ Without RAG          │ With RAG              │
   ├──────────────────────┼───────────────────────┤
   │ LLM → Answer         │ Search → LLM → Answer │
   │ May hallucinate      │ Grounded in docs      │
   │ Can't verify         │ Can verify sources    │
   │ Generic answers      │ Specific answers      │
   │ No control           │ Full control          │
   └──────────────────────┴───────────────────────┘
   
   RAG = RETRIEVAL + AUGMENTATION + GENERATION
   
   Example:
   ❌ Without RAG: "Battery lasts 40 hours" (hallucination)
   ✅ With RAG: "Battery lasts 30 hours" (from DOC-001)

4. SEARCH SCORING AND RELEVANCE
   Score Ranges:
   0.9-1.0 : Exact match or near-perfect relevance
   0.7-0.9 : Highly relevant
   0.5-0.7 : Relevant
   0.3-0.5 : Somewhat relevant
   < 0.3   : Low relevance (consider filtering out)
   
   Use cases:
   - HIGH confidence: score > 0.8, show answer
   - MEDIUM confidence: score 0.5-0.8, show with caveat
   - LOW confidence: score < 0.5, suggest human review

5. FILTERING AND ATTRIBUTES
   Available operators:
   @eq  : Equals
   @ne  : Not equals
   @gt  : Greater than
   @lt  : Less than
   @gte : Greater than or equal
   @lte : Less than or equal
   @in  : In list
   @and : Combine conditions
   @or  : Either condition

📊 PRODUCTION PATTERNS
===================

PATTERN 1: Customer Support Automation
┌────────────────────────────────────────────────┐
│ Ticket arrives                                 │
│   ↓                                            │
│ Translate to English (if needed)              │
│   ↓                                            │
│ Search documentation (semantic)                │
│   ↓                                            │
│ Generate response (RAG)                        │
│   ↓                                            │
│ Translate response back (if needed)           │
│   ↓                                            │
│ Send to customer                               │
└────────────────────────────────────────────────┘

PATTERN 2: Knowledge Base Chatbot
┌────────────────────────────────────────────────┐
│ User asks question                             │
│   ↓                                            │
│ Search docs (top 3 results)                    │
│   ↓                                            │
│ Check relevance score                          │
│   ↓                                            │
│ IF score > 0.5:                                │
│   Generate answer from docs                    │
│ ELSE:                                          │
│   Return "no documentation found"              │
│   Provide contact information                  │
└────────────────────────────────────────────────┘

PATTERN 3: Review Analysis
┌────────────────────────────────────────────────┐
│ Search reviews for feature                    │
│   ↓                                            │
│ Get top 10-20 reviews                          │
│   ↓                                            │
│ Use LLM to summarize                           │
│   ↓                                            │
│ Extract: positive, negative, overall           │
│   ↓                                            │
│ Present to product team                        │
└────────────────────────────────────────────────┘

💰 COST AND PERFORMANCE
=====================

COSTS:
Search Service:
- Indexing: ~$0.01 per 1,000 docs (one-time)
- Storage: Minimal (vector embeddings)
- Queries: Very low cost per search

LLM Calls (COMPLETE):
- Token-based pricing
- Varies by model (mixtral < llama3 < mistral-large)
- Typical: $0.001-0.005 per query

Optimization:
✓ Cache frequent queries
✓ Limit search results (LIMIT 3 vs 10)
✓ Use LEFT() to truncate long docs
✓ Choose right model for task
✓ Batch process when possible

PERFORMANCE:
Search: < 100ms typical
LLM: 1-3 seconds typical
Total: < 5 seconds end-to-end

🚀 PRODUCTION DEPLOYMENT
======================

PRE-LAUNCH CHECKLIST:
□ Search service indexed and ACTIVE
□ Test queries return relevant results
□ RAG responses are accurate
□ Confidence scoring implemented
□ Source tracking working
□ Multi-language tested (if applicable)
□ Error handling for edge cases
□ Fallback contact info provided
□ Monitoring dashboards created
□ Cost alerts configured

MONITORING METRICS:
- Queries per day/hour
- Average search score
- Confidence distribution
- Answer rate (% successful)
- Average response time
- Token usage and cost
- User feedback (thumbs up/down)
- Common "no data" queries

CONTINUOUS IMPROVEMENT:
1. Track low-confidence queries
2. Identify documentation gaps
3. Refine search prompts
4. A/B test different approaches
5. Collect user feedback
6. Update docs based on gaps
7. Iterate on prompts
8. Monitor quality drift

⚠️ COMMON PITFALLS
=================

PITFALL 1: Search service not ACTIVE
❌ Querying before indexing complete
✅ Check DESCRIBE...SERVICE shows "ACTIVE"

PITFALL 2: Too many search results
❌ LIMIT 10 = more context but higher cost
✅ LIMIT 3 = usually sufficient, lower cost

PITFALL 3: Not filtering low relevance
❌ Including results with score < 0.3
✅ WHERE search_score > 0.3

PITFALL 4: Forgetting to translate back
❌ Spanish question → English answer
✅ Spanish question → English processing → Spanish answer

PITFALL 5: No fallback for no results
❌ Empty response when no docs found
✅ "Contact support" message

PITFALL 6: Hallucination in RAG
❌ LLM makes up info not in docs
✅ Prompt: "ONLY use provided docs"

PITFALL 7: No source tracking
❌ Can't verify where answer came from
✅ Track doc IDs/titles used

PITFALL 8: Ignoring confidence scores
❌ Showing all answers equally
✅ Flag low-confidence for review

🎓 WHAT YOU'VE ACCOMPLISHED
==========================

ACROSS ALL 3 WORKSHEETS:

WORKSHEET 1: Foundation
✓ SENTIMENT - Emotional analysis
✓ TRANSLATE - Language barriers removed
✓ SUMMARIZE - Information condensed
✓ Function nesting and composition

WORKSHEET 2: Advanced LLM
✓ COMPLETE - Full LLM power
✓ Classification and categorization
✓ Extraction and structuring
✓ Content generation
✓ Model selection and comparison

WORKSHEET 3: Semantic Search & RAG
✓ CORTEX SEARCH - Semantic search
✓ RAG pattern - Grounded responses
✓ Production chatbots
✓ Multi-language support
✓ Quality assurance

REAL-WORLD APPLICATIONS:
✓ Automated customer support
✓ Knowledge base Q&A
✓ Multi-language documentation
✓ Review sentiment analysis
✓ Product issue detection
✓ Content generation
✓ Document classification
✓ Information extraction

🎯 FINAL TAKEAWAY
===============

You can now build sophisticated AI applications using ONLY SQL!

No Python required
No external APIs needed
No complex infrastructure
No model deployment
No data science team

Everything runs in Snowflake:
- Your data
- Your AI models
- Your business logic
- Your governance

= Unified platform for data + AI

🚀 NEXT STEPS
============

1. BUILD YOUR OWN:
   - Try with your company's data
   - Create custom search services
   - Build domain-specific chatbots

2. EXPLORE MORE:
   - Cortex Analyst (NL to SQL)
   - Cortex Fine-Tuning (custom models)
   - Streamlit in Snowflake (UI)

3. SHARE KNOWLEDGE:
   - Show your manager/team
   - Present use cases
   - Propose pilot projects

4. STAY UPDATED:
   - docs.snowflake.com/cortex
   - Snowflake blog
   - Community forums

CONGRATULATIONS! 🎉
You've mastered Snowflake Cortex AI!
*/
