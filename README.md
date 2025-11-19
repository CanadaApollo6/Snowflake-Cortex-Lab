# Snowflake Cortex AI Lab

An interactive, hands-on workshop that teaches data professionals how to harness the power of AI directly within Snowflake using Cortex AI functions—no Python, no external APIs, just SQL.

[![Snowflake](https://img.shields.io/badge/Snowflake-Cortex%20AI-29B5E8?logo=snowflake&logoColor=white)](https://www.snowflake.com/en/data-cloud/cortex/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Workshop Duration](https://img.shields.io/badge/Duration-50%20minutes-blue)](.)

## Overview

This lab guides participants through real-world AI use cases using Snowflake Cortex—from sentiment analysis and translation to semantic search and retrieval-augmented generation (RAG). Designed for data analysts, engineers, and scientists who want to add AI capabilities to their Snowflake workflows without learning new programming languages.

### What You'll Learn

- 🎯 **Sentiment Analysis** - Automatically detect customer emotions in support tickets
- 🌍 **Multi-language Translation** - Break down language barriers in global data
- 📝 **Text Summarization** - Condense lengthy documents into key insights
- 🤖 **LLM Integration** - Use large language models for classification, extraction, and generation
- 🔍 **Semantic Search** - Find documents by meaning, not just keywords
- 💡 **RAG Patterns** - Build accurate, grounded AI applications that prevent hallucination

### Lab Structure

| Worksheet | Topic | Time | Difficulty | Key Concepts |
|-----------|-------|------|------------|--------------|
| [01](worksheets/worksheet-01.sql) | **Cortex LLM Functions** | 15 min | Beginner | SENTIMENT, TRANSLATE, SUMMARIZE |
| [02](worksheets/worksheet-02.sql) | **Cortex Complete** | 20 min | Intermediate | COMPLETE, prompting, classification, extraction |
| [03](worksheets/worksheet-03.sql) | **Cortex Search & RAG** | 15 min | Advanced | Semantic search, vector embeddings, RAG patterns |

**Total Duration:** ~45 minutes (including setup and buffer time)

## Prerequisites

- Active Snowflake account with ACCOUNTADMIN access
- Snowflake Cortex features enabled (available in most regions)
- Basic SQL knowledge
- Web browser for Snowflake web interface or SnowSQL CLI

## Quick Start

### 🎯 Self-Guided Learning (Try It Yourself!)

Want to try this lab on your own or continue after the workshop?

**5-Minute Setup:**

1. Get a free Snowflake trial at [signup.snowflake.com](https://signup.snowflake.com) ($400 in free credits!)
2. Run [self-service-setup.sql](post_lab_materials/self-service-setup.sql) - one script does everything
3. Start with [Worksheet 1](worksheets/worksheet-01.sql)

**📖 Detailed Guide:** See [SELF_GUIDED_SETUP.md](post_lab_materials/SELF_GUIDED_SETUP.md) for step-by-step instructions, troubleshooting, and ideas for your own data.

**💰 Cost:** Less than $1 to complete all 3 worksheets in your trial account.

---

### For Workshop Organizers

**📖 Full Instructor Guide:** See [INSTRUCTOR_GUIDE.md](INSTRUCTOR_GUIDE.md) for complete facilitation instructions, timing guide, troubleshooting, and delivery tips.

**Quick Setup:**

1. **Provision Lab Accounts** (5 minutes before workshop)

   ```sql
   -- Run as ACCOUNTADMIN
   -- Adjust password and number of users in lab_setup/account-provision.sql
   @lab_setup/account-provision.sql
   ```

   This creates 30 isolated lab accounts with dedicated workspaces.

2. **Load Sample Data** (2 minutes)

   ```sql
   @lab_setup/sample-data.sql
   ```

   Loads realistic datasets: support tickets (multi-language), product reviews, documentation, and sales transcripts.

3. **Distribute Credentials**
   - Use the credential export query in [account-provision.sql](lab_setup/account-provision.sql:169-179)
   - Share Snowflake account URL with participants

4. **End-of-Workshop Handout**
   - Give participants [WORKSHOP_HANDOUT.md](post_lab_materials/WORKSHOP_HANDOUT.md) or link to this repo
   - Point them to [self-service-setup.sql](post_lab_materials/self-service-setup.sql) for their own accounts
   - Encourage them to get a free trial and continue learning

### For Participants

1. Log in with provided credentials
2. Open [Worksheet 1](worksheets/worksheet-01.sql) in Snowflake
3. Follow along with instructor, running queries step-by-step

## Sample Data

The lab includes four realistic datasets designed to showcase Cortex capabilities:

| Dataset | Records | Description | Use Cases |
|---------|---------|-------------|-----------|
| **Customer Support Tickets** | 15+ | Multi-language tickets with varying sentiment | Translation, sentiment analysis, classification |
| **Product Reviews** | 15+ | 1-5 star reviews across multiple products | Sentiment analysis, content generation |
| **Product Documentation** | 10+ | User manuals, troubleshooting guides, FAQs | Summarization, semantic search, RAG |
| **Sales Transcripts** | 4+ | Realistic sales call conversations | Extraction, summarization, analysis |

**Languages Supported:** English, Spanish, French, German, Japanese, Chinese

## Workshop Exercises

### Worksheet 1: Foundation - Cortex LLM Functions (15 min)

Learn the building blocks of Cortex AI:

- Analyze customer sentiment to prioritize urgent issues
- Translate multi-language tickets for global support teams
- Summarize lengthy documentation for quick reference
- Combine multiple Cortex functions in sophisticated workflows

**Key Query Example:**

```sql
-- Translate non-English tickets and analyze sentiment
SELECT
  ticket_id,
  SNOWFLAKE.CORTEX.TRANSLATE(subject, language, 'en') AS english_subject,
  SNOWFLAKE.CORTEX.SENTIMENT(description) AS sentiment_score
FROM CUSTOMER_SUPPORT_TICKETS
WHERE language != 'en';
```

### Worksheet 2: Power - Cortex Complete (12 min)

Harness the full power of large language models:

- Automatically classify support tickets into categories
- Extract structured data from unstructured text
- Generate personalized responses to customer reviews
- Compare different LLM models for your use case
- Build an automated ticket triage system

**Key Query Example:**

```sql
-- Classify support tickets using LLM
SELECT
  ticket_id,
  subject,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b',
    'Categorize this ticket (one word): shipping, product_quality, payment, or technical.

    Ticket: ' || subject || '

    Category:'
  ) AS ticket_category
FROM CUSTOMER_SUPPORT_TICKETS;
```

### Worksheet 3: Advanced - Cortex Search & RAG (15 min)

Build intelligent search and Q&A systems:

- Create semantic search services on documentation
- Search by meaning, not just keywords
- Implement Retrieval-Augmented Generation (RAG) patterns
- Build a knowledge base chatbot
- Auto-generate support responses from documentation

**Key Query Example:**

```sql
-- RAG: Search docs + LLM for accurate answers
WITH search_results AS (
  SELECT content
  FROM TABLE(PRODUCT_DOCS_SEARCH!SEARCH('How do I pair the headphones?'))
  LIMIT 3
)
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'mixtral-8x7b',
  'Answer this question using ONLY the provided documentation:

  Question: How do I pair the UltraSound Pro headphones?

  Documentation: ' || LISTAGG(content, '\n') || '

  Answer:'
) AS ai_answer
FROM search_results;
```

## Post-Workshop Cleanup

After the workshop concludes (typically 7-14 days later):

```sql
-- Run as ACCOUNTADMIN
@lab_setup/account-cleanup.sql
```

This removes all lab accounts, workspaces, and optionally the sample data to clean up your Snowflake environment.

## Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                    SNOWFLAKE ACCOUNT                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐      ┌──────────────────────────────┐     │
│  │  LAB_DATA DB     │      │  30 User Accounts            │     │
│  ├──────────────────┤      │  (cortexlab01-30)            │     │
│  │ • SAMPLES        │◄─────┤  Each with:                  │     │
│  │   (shared data)  │      │  • Personal workspace schema │     │
│  │                  │      │  • Read access to shared data│     │
│  │ • CORTEX_SERVICES│      │  • CORTEX_USER privileges    │     │
│  │   (search)       │      └──────────────────────────────┘     │
│  └──────────────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────────────────────────────────────────┐       │
│  │         CORTEX_LAB_WH (Shared Warehouse)             │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Real-World Applications

Participants learn patterns applicable to:

- **Customer Support:** Auto-triage tickets, generate responses, sentiment tracking
- **Product Analytics:** Review analysis, feature extraction, competitive intelligence
- **Content Management:** Document summarization, FAQ generation, knowledge bases
- **Sales Operations:** Call transcript analysis, lead scoring, action item extraction
- **Global Operations:** Multi-language support, translation workflows, localization

## Technologies Used

- **Snowflake Cortex AI** - Fully managed AI/ML functions
  - `SNOWFLAKE.CORTEX.SENTIMENT()` - Sentiment analysis
  - `SNOWFLAKE.CORTEX.TRANSLATE()` - Language translation
  - `SNOWFLAKE.CORTEX.SUMMARIZE()` - Text summarization
  - `SNOWFLAKE.CORTEX.COMPLETE()` - Full LLM access (Mixtral, Mistral, Llama)
  - `CORTEX SEARCH SERVICE` - Semantic search with vector embeddings

- **Models Available:**
  - Mixtral-8x7b (fast, cost-effective)
  - Mistral-large (enhanced reasoning)
  - Llama 3 (70b and 8b variants)

## Files Structure

```text
Snowflake-Cortex-Lab/
├── README.md                          # This file - overview and quick start
├── INSTRUCTOR_GUIDE.md               # Complete guide for workshop facilitators
├── SELF_GUIDED_SETUP.md              # Detailed guide for self-paced learning
├── WORKSHOP_HANDOUT.md               # Take-home resource for workshop participants
├── self-service-setup.sql            # One-click setup for trial accounts
├── lab_setup/
│   ├── account-provision.sql         # Creates 30 lab accounts + infrastructure
│   ├── sample-data.sql               # Loads realistic sample datasets
│   └── account-cleanup.sql           # Removes all lab resources
├── worksheets/
│   ├── worksheet-01.sql              # Basic Cortex functions (15 min)
│   ├── worksheet-02.sql              # CORTEX.COMPLETE and prompting (12 min)
│   └── worksheet-03.sql              # Cortex Search and RAG patterns (15 min)
└── answer_keys/
    ├── README.md                     # Guide to using answer keys
    ├── worksheet-01-answers.sql      # Solutions for Worksheet 1
    ├── worksheet-02-answers.sql      # Solutions for Worksheet 2
    └── worksheet-03-answers.sql      # Solutions for Worksheet 3
```

## Customization

### Adjust Number of Users

Edit [account-provision.sql](lab_setup/account-provision.sql:75):

```sql
SET NUM_USERS = 30;  -- Change to desired number
```

### Change Password

Edit [account-provision.sql](lab_setup/account-provision.sql:76):

```sql
SET PASSWORD = 'YourSecurePassword123!';
```

### Add Custom Data

Add your own tables to `LAB_DATA.SAMPLES` schema for company-specific use cases.

## FAQ

**Q: What Snowflake edition is required?**
A: Enterprise Edition or higher recommended. Cortex features must be enabled (available in most AWS/Azure regions).

**Q: What are the costs?**
A: Cortex functions are billed per-token. For a 45-minute lab with 30 users, expect minimal costs (<$10 total). The warehouse cost depends on your warehouse size.

**Q: Can participants use their own Snowflake accounts?**
A: Yes! They can run [sample-data.sql](lab_setup/sample-data.sql) in their own trial accounts.

**Q: How do I get a Snowflake trial account?**
A: Visit [signup.snowflake.com](https://signup.snowflake.com) for a free 30-day trial with $400 credits.

**Q: Can this be self-paced?**
A: Absolutely! All worksheets have detailed instructions and can be completed independently.

## Contributing

Suggestions and improvements welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the Apache License 2.0 - feel free to use it for your workshops, training, or learning. See the LICENSE file for details.

## Resources

- [Snowflake Cortex Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/overview)
- [Cortex LLM Functions](https://docs.snowflake.com/en/user-guide/snowflake-cortex/llm-functions)
- [Cortex Search Service](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Snowflake Community](https://community.snowflake.com/)

## Author

Created for Smart Data clients and the Snowflake community.

**Workshop Contact:** For workshop facilitation or questions, reach out through GitHub issues.

---

⭐ **Star this repo** if you found it helpful for learning Snowflake Cortex AI!

🔗 **Share** with your team to bring AI capabilities to your data warehouse!
