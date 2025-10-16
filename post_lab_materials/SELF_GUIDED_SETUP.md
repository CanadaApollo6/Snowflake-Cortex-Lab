# Self-Guided Lab Setup - Try It Yourself

Want to continue learning after the workshop or try this lab on your own? This guide will help you set up the complete Cortex AI Lab in your personal Snowflake trial account in less than 5 minutes.

## Prerequisites

- **Snowflake Trial Account** - Get your free 30-day trial with $400 credits at [signup.snowflake.com](https://signup.snowflake.com)
- **Web Browser** - For Snowflake's web interface
- **5 Minutes** - That's all you need!

## Quick Setup (2 Options)

### Option 1: One-Click Setup (Recommended)

Run this single script that does everything for you:

1. **Log into your Snowflake trial account**
2. **Create a new SQL Worksheet**
3. **Copy and paste the contents of [self-service-setup.sql](self-service-setup.sql)**
4. **Run All** (Ctrl/Cmd + Shift + Enter)
5. **Wait 2-3 minutes** for data loading and search service creation

That's it! Jump to [What's Next](#whats-next) below.

### Option 2: Step-by-Step Setup

If you prefer to understand each step:

#### Step 1: Create Database and Warehouse (30 seconds)

```sql
-- Run as your default role (usually ACCOUNTADMIN in trial accounts)
USE ROLE ACCOUNTADMIN;

-- Create dedicated warehouse
CREATE WAREHOUSE IF NOT EXISTS CORTEX_LAB_WH
  WITH WAREHOUSE_SIZE = 'SMALL'  -- Small is perfect for learning
       AUTO_SUSPEND = 60
       AUTO_RESUME = TRUE
       INITIALLY_SUSPENDED = TRUE;

-- Create lab database
CREATE DATABASE IF NOT EXISTS LAB_DATA;
USE DATABASE LAB_DATA;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS SAMPLES;
CREATE SCHEMA IF NOT EXISTS CORTEX_SERVICES;
CREATE SCHEMA IF NOT EXISTS MY_WORKSPACE;

-- Grant yourself Cortex privileges
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE ACCOUNTADMIN;
```

#### Step 2: Load Sample Data (1-2 minutes)

Copy the entire contents of [lab_setup/sample-data.sql](lab_setup/sample-data.sql) and run it.

This creates:

- **CUSTOMER_SUPPORT_TICKETS** (15 multi-language tickets)
- **PRODUCT_REVIEWS** (15 reviews with ratings)
- **PRODUCT_DOCS** (10 documentation articles)
- **SALES_TRANSCRIPTS** (4 realistic sales calls)

#### Step 3: Start Learning! (30 seconds)

Open the worksheets in order:

1. [worksheets/worksheet-01.sql](worksheets/worksheet-01.sql) - Basic Cortex Functions
2. [worksheets/worksheet-02.sql](worksheets/worksheet-02.sql) - CORTEX.COMPLETE
3. [worksheets/worksheet-03.sql](worksheets/worksheet-03.sql) - Cortex Search & RAG

## What's Next?

### Immediate Next Steps

1. **Complete all 3 worksheets** at your own pace (no rush!)
2. **Try the advanced exercises** in Worksheet 3 (3.7-3.10)
3. **Modify the examples** with your own prompts and questions
4. **Experiment with different LLM models** (mixtral-8x7b, mistral-large, llama3-70b)

### Bring Your Own Data

Once you're comfortable, try these exercises with your own data:

#### Example: Analyze Your Own Text Data

```sql
-- Create a table with your own text data
CREATE TABLE MY_WORKSPACE.MY_DATA AS
SELECT
  'Your text here' AS text_column,
  'metadata' AS category;

-- Analyze sentiment
SELECT
  text_column,
  SNOWFLAKE.CORTEX.SENTIMENT(text_column) AS sentiment,
  category
FROM MY_WORKSPACE.MY_DATA;

-- Summarize long content
SELECT
  SNOWFLAKE.CORTEX.SUMMARIZE(text_column) AS summary
FROM MY_WORKSPACE.MY_DATA;

-- Extract information with LLM
SELECT
  text_column,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Extract key themes from this text: ' || text_column
  ) AS themes
FROM MY_WORKSPACE.MY_DATA;
```

#### Example: Create Your Own Search Service

```sql
-- Create a search service on your own documents
CREATE OR REPLACE CORTEX SEARCH SERVICE MY_WORKSPACE.MY_SEARCH_SERVICE
ON text_column
ATTRIBUTES category
WAREHOUSE = CORTEX_LAB_WH
TARGET_LAG = '1 minute'
AS (
  SELECT
    row_id,
    text_column,
    category
  FROM MY_WORKSPACE.MY_DATA
);

-- Wait 30-60 seconds, then search!
SELECT *
FROM TABLE(
  MY_WORKSPACE.MY_SEARCH_SERVICE!SEARCH('your search query here')
)
LIMIT 5;
```

## Real-World Use Cases to Try

### 1. Customer Support Automation

Build a system that:

- Analyzes incoming support emails for sentiment
- Categorizes tickets automatically
- Searches knowledge base for relevant solutions
- Generates draft responses

**Start with:** Worksheet 2, Exercise 2.6 + Worksheet 3, Exercise 3.5

### 2. Document Intelligence

Create a document Q&A system:

- Upload company PDFs/docs as text
- Create Cortex Search service
- Implement RAG pattern for accurate answers
- Build a chatbot function

**Start with:** Worksheet 3, Exercises 3.2-3.4

### 3. Multi-Language Content Analysis

Analyze global feedback:

- Translate all content to English
- Perform sentiment analysis
- Generate summaries
- Extract common themes

**Start with:** Worksheet 1, Exercise 1.4

### 4. Sales Intelligence

Analyze sales calls and emails:

- Summarize conversations
- Extract action items
- Identify objections
- Score lead quality

**Start with:** Worksheet 2, Exercise 2.3

## Cost Management Tips

Your Snowflake trial includes $400 in free credits. Here's how to make them last:

### Keep Costs Low

1. **Use SMALL warehouses** - Perfect for learning (costs ~$1/hour when running)
2. **Enable AUTO_SUSPEND** - Warehouse stops after 60 seconds of inactivity
3. **Use mixtral-8x7b model** - Most cost-effective LLM option
4. **Limit query results** - Use `LIMIT 5` or `LIMIT 10` when testing
5. **Suspend when done** - Run `ALTER WAREHOUSE CORTEX_LAB_WH SUSPEND;`

### Expected Costs for This Lab

- **Full lab completion:** < $0.50
- **All 3 worksheets + advanced exercises:** ~$1-2
- **Entire 30-day trial experimenting:** $5-20 (leaving you plenty of credits!)

Cortex functions are **very inexpensive** - billed per token, typically pennies per query.

## Troubleshooting

### "Cortex function not found"

**Solution:** Grant yourself Cortex privileges:

```sql
USE ROLE ACCOUNTADMIN;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE ACCOUNTADMIN;
```

### "Cortex Search service creation failed"

**Possible causes:**

1. **Region not supported** - Cortex Search is available in most AWS/Azure regions
2. **Account type** - Need Enterprise or higher (trial accounts have Enterprise)

**Check region support:**

```sql
SELECT CURRENT_REGION();
```

Visit [Snowflake docs](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview#region-availability) for supported regions.

### "Search service indexing takes too long"

**Expected:** 30-60 seconds for our small dataset (10 docs)
**If longer:** Check if warehouse is running:

```sql
SHOW WAREHOUSES LIKE 'CORTEX_LAB_WH';
ALTER WAREHOUSE CORTEX_LAB_WH RESUME;
```

### "Out of credits"

**Check remaining credits:**

```sql
-- Contact Snowflake support or check your account page
-- Trial accounts can request credit extensions
```

## Additional Resources

### Snowflake Documentation

- [Cortex AI Overview](https://docs.snowflake.com/en/user-guide/snowflake-cortex/overview)
- [LLM Functions Reference](https://docs.snowflake.com/en/user-guide/snowflake-cortex/llm-functions)
- [Cortex Search Guide](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Cortex Analyst (NL-to-SQL)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)

### Community & Support

- [Snowflake Community](https://community.snowflake.com/) - Ask questions, share ideas
- [Cortex AI Discussions](https://community.snowflake.com/s/topic/0TO5Y000000N4MHWA0/cortex) - Specific to Cortex features
- [GitHub Issues](https://github.com/yourusername/Snowflake-Cortex-Lab/issues) - For this lab specifically

### Sample Projects & Ideas

1. **Build a company knowledge base chatbot**
   - Upload your company docs
   - Create search service
   - Implement RAG pattern
   - Deploy via Streamlit in Snowflake

2. **Automate email responses**
   - Classify incoming emails
   - Search for relevant templates
   - Generate personalized responses
   - Route to appropriate teams

3. **Product review dashboard**
   - Ingest reviews from multiple sources
   - Analyze sentiment trends over time
   - Extract common complaints/praises
   - Generate executive summaries

4. **Meeting intelligence system**
   - Store meeting transcripts
   - Extract action items automatically
   - Search past meetings semantically
   - Generate follow-up emails

## Keep Learning

### Expand Your Knowledge

1. **Cortex Fine-Tuning** - Train models on your specific data
2. **Cortex Analyst** - Natural language to SQL queries
3. **Streamlit + Cortex** - Build AI-powered data apps
4. **Vector Embeddings** - Advanced similarity search
5. **Document AI** - OCR and document understanding

### Join the Community

- Share what you built on LinkedIn with #SnowflakeCortex
- Post questions in Snowflake Community forums
- Contribute examples back to this repo via pull requests
- Connect with other data professionals exploring AI

## Cleanup (Optional)

When you're done experimenting and want to clean up:

```sql
-- Remove all lab objects
USE ROLE ACCOUNTADMIN;

DROP DATABASE IF EXISTS LAB_DATA CASCADE;
DROP WAREHOUSE IF EXISTS CORTEX_LAB_WH;

-- Your Snowflake trial account is now clean!
```

---

## Need Help?

- **Questions about this lab?** [Open a GitHub issue](https://github.com/yourusername/Snowflake-Cortex-Lab/issues)
- **Snowflake account issues?** [Contact Snowflake Support](https://community.snowflake.com/s/article/How-To-Submit-a-Support-Case-in-Snowflake-Lodge)
- **Want to run a workshop?** See [README.md](README.md) for instructor guide

---

## Happy Learning! 🎉

Remember: The best way to learn is by doing. Don't be afraid to experiment, break things, and try new ideas. That's what trial accounts are for!
