# Snowflake Cortex AI Lab - Take-Home Resources

**Thank you for attending the Snowflake Cortex AI Lab!** 🎉

This handout contains everything you need to continue your learning journey.

---

## 📚 What You Learned Today

### Worksheet 1: Cortex LLM Functions

- ✅ **SENTIMENT** - Analyze emotions in customer feedback
- ✅ **TRANSLATE** - Break down language barriers
- ✅ **SUMMARIZE** - Condense lengthy documents
- ✅ **Function Composition** - Combine multiple Cortex functions

### Worksheet 2: CORTEX.COMPLETE

- ✅ **Text Classification** - Auto-categorize support tickets
- ✅ **Data Extraction** - Pull structured info from unstructured text
- ✅ **Content Generation** - Create responses and summaries
- ✅ **Model Selection** - Choose the right LLM for your task

### Worksheet 3: Cortex Search & RAG

- ✅ **Semantic Search** - Find documents by meaning, not keywords
- ✅ **Cortex Search Service** - Vector-based document search
- ✅ **RAG Pattern** - Prevent hallucinations with grounded answers
- ✅ **Knowledge Base Q&A** - Build intelligent chatbots

---

## 🏠 Continue Learning at Home

### Option 1: Quick Setup (5 minutes)

**Get your own Snowflake trial:**

1. Visit **signup.snowflake.com**
2. Sign up for free trial ($400 credits included)
3. Log in and create a new SQL worksheet
4. Copy contents of **self-service-setup.sql** from this repo
5. Run it and you're ready to go!

**Repository:** [github.com/yourname/Snowflake-Cortex-Lab](https://github.com/yourname/Snowflake-Cortex-Lab)

### Option 2: Detailed Guide

Download **SELF_GUIDED_SETUP.md** for:

- Step-by-step setup instructions
- Troubleshooting common issues
- Ideas for using your own data
- Real-world project examples
- Cost management tips

---

## 💡 Quick Reference: Cortex Functions

### Sentiment Analysis

```sql
SELECT SNOWFLAKE.CORTEX.SENTIMENT(text_column) AS sentiment
FROM your_table;
-- Returns: -1 (very negative) to +1 (very positive)
```

### Translation

```sql
SELECT SNOWFLAKE.CORTEX.TRANSLATE(
  text_column,
  'source_language',  -- e.g., 'es' for Spanish
  'target_language'   -- e.g., 'en' for English
) AS translated_text
FROM your_table;
```

### Summarization

```sql
SELECT SNOWFLAKE.CORTEX.SUMMARIZE(long_text_column) AS summary
FROM your_table;
```

### LLM Completion

```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',  -- Model name
  'Your prompt here: ' || text_column
) AS llm_response
FROM your_table;
```

### Semantic Search

```sql
-- First, create a search service (one-time setup)
CREATE CORTEX SEARCH SERVICE my_search
ON text_column
ATTRIBUTES category, date
WAREHOUSE = my_warehouse
TARGET_LAG = '1 minute'
AS (SELECT * FROM my_table);

-- Then search with natural language
SELECT *
FROM TABLE(my_search!SEARCH('your natural language query'))
LIMIT 5;
```

### RAG Pattern (Search + LLM)

```sql
WITH search_results AS (
  SELECT content
  FROM TABLE(my_search!SEARCH('user question'))
  LIMIT 3
)
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',
  'Answer this question using only the provided docs:

  Question: [user question]

  Documentation: ' || LISTAGG(content, '\n') || '

  Answer:'
) AS accurate_answer
FROM search_results;
```

---

## 🎯 Real-World Use Cases

### Customer Support Automation

**What:** Auto-triage tickets, generate responses, track sentiment
**Start with:** Worksheet 2 (Exercise 2.6) + Worksheet 3 (Exercise 3.5)

### Document Intelligence

**What:** Q&A system on company docs, semantic search
**Start with:** Worksheet 3 (Exercises 3.2-3.4)

### Multi-Language Analysis

**What:** Translate and analyze global customer feedback
**Start with:** Worksheet 1 (Exercise 1.4)

### Sales Intelligence

**What:** Summarize calls, extract action items, score leads
**Start with:** Worksheet 2 (Exercise 2.3)

### Content Moderation

**What:** Classify and filter user-generated content
**Start with:** Worksheet 2 (Exercise 2.2)

---

## 💰 Trial Account Tips

Your Snowflake trial includes:

- **$400 in free credits** (lasts months for learning!)
- **30 days** of full Enterprise Edition features
- **All Cortex AI functions** included

**Keep costs low:**

- ✅ Use SMALL warehouses for learning
- ✅ Enable AUTO_SUSPEND (stops after 60 seconds idle)
- ✅ Use `mixtral-8x7b` model (most cost-effective)
- ✅ Add `LIMIT 10` to test queries
- ✅ Suspend warehouse when done: `ALTER WAREHOUSE name SUSPEND;`

**Expected costs:**

- This full lab: < $1
- Month of learning: $5-20 (leaving plenty of credits!)

---

## 📖 Resources

### Official Documentation

- [Cortex AI Overview](https://docs.snowflake.com/en/user-guide/snowflake-cortex/overview)
- [LLM Functions](https://docs.snowflake.com/en/user-guide/snowflake-cortex/llm-functions)
- [Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst) - Natural language to SQL!

### Community

- [Snowflake Community](https://community.snowflake.com/)
- [Cortex Discussions](https://community.snowflake.com/s/topic/0TO5Y000000N4MHWA0/cortex)
- LinkedIn: #SnowflakeCortex #SnowflakeAI

### This Lab Repository

- **Code:** github.com/yourname/Snowflake-Cortex-Lab
- **Issues/Questions:** Open a GitHub issue
- **Contributions:** Pull requests welcome!

---

## 🚀 Next Steps Checklist

After this workshop:

- [ ] Sign up for Snowflake trial (signup.snowflake.com)
- [ ] Run self-service-setup.sql in your account
- [ ] Complete any exercises you didn't finish
- [ ] Try the advanced exercises (Worksheet 3, 3.7-3.10)
- [ ] Experiment with your own data
- [ ] Build one of the real-world use cases above
- [ ] Share what you built on LinkedIn!
- [ ] Join Snowflake Community forums
- [ ] Explore Cortex Analyst for NL-to-SQL

---

## 📊 Sample Projects to Try

### Project 1: Personal Email Assistant

**Goal:** Analyze your email data (export to CSV)
**Skills:** Sentiment, Classification, Summarization
**Time:** 2-3 hours

### Project 2: Document Q&A Bot

**Goal:** Upload PDFs, create searchable knowledge base
**Skills:** Cortex Search, RAG Pattern
**Time:** 3-4 hours

### Project 3: Multi-Language Support Dashboard

**Goal:** Translate and analyze global customer feedback
**Skills:** Translation, Sentiment, Visualization
**Time:** 2-3 hours

### Project 4: Meeting Notes Analyzer

**Goal:** Extract action items from transcripts
**Skills:** COMPLETE, Data Extraction
**Time:** 1-2 hours

---

## ❓ FAQ

**Q: How long does my trial last?**
A: 30 days, but your credits don't expire if you convert to paid.

**Q: What happens after $400 in credits?**
A: Snowflake pauses services. You can add payment method to continue or contact them for credit extension for learning.

**Q: Can I use this for my company?**
A: Yes! Just replace sample data with your company data. Talk to Snowflake sales about production accounts.

**Q: Is Cortex available in all regions?**
A: Most AWS and Azure regions. Check [docs](https://docs.snowflake.com/en/user-guide/snowflake-cortex/llm-functions#availability) for your region.

**Q: How do I get help?**
A: Post in Snowflake Community forums or open an issue on this GitHub repo.

**Q: Can I share this lab?**
A: Yes! Share freely. It's open source (Apache 2.0 License).

---

## 📧 Stay Connected

**Workshop Feedback:** [your-email@example.com]

**Repository:** github.com/yourname/Snowflake-Cortex-Lab

**Instructor LinkedIn:** [Your LinkedIn]

**Share Your Progress:**

- LinkedIn: Tag @Snowflake, use #SnowflakeCortex
- Twitter/X: @SnowflakeDB #SnowflakeAI
- Community: community.snowflake.com

---

## 🙏 Thank You

Thank you for attending the Snowflake Cortex AI Lab! We hope you enjoyed learning how to bring AI capabilities directly into your data warehouse with just SQL.

**Remember:** The best way to learn is by doing. Don't be afraid to experiment, break things, and try new ideas in your trial account. That's what it's for!

**Questions?** Reach out anytime via GitHub issues or Snowflake Community.

**Happy Building!** 🚀

---

*Generated with assistance from Snowflake Cortex AI* 😉

---

## Quick Command Reference Card

```sql
-- Check your credits
SELECT * FROM SNOWFLAKE.ORGANIZATION_USAGE.USAGE_IN_CURRENCY_DAILY
ORDER BY DATE DESC LIMIT 30;

-- Suspend warehouse to save credits
ALTER WAREHOUSE CORTEX_LAB_WH SUSPEND;

-- Resume warehouse
ALTER WAREHOUSE CORTEX_LAB_WH RESUME;

-- Check search service status
DESCRIBE CORTEX SEARCH SERVICE my_search_service;

-- Grant Cortex privileges
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE ACCOUNTADMIN;

-- List available models
-- Visit: docs.snowflake.com/cortex/llm-functions#available-models
```

---

**Print this handout or bookmark this page for quick reference!**
