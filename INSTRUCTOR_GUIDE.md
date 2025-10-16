# Snowflake Cortex AI Lab - Instructor Guide

## For Presenters, Speakers, and Workshop Facilitators

This guide contains everything you need to successfully deliver the Snowflake Cortex AI Lab workshop, whether you're teaching 5 people or 30.

---

## Table of Contents

1. [Workshop Overview](#workshop-overview)
2. [Pre-Workshop Preparation](#pre-workshop-preparation)
3. [Delivery Guide](#delivery-guide)
4. [Troubleshooting](#troubleshooting)
5. [Post-Workshop](#post-workshop)
6. [Tips for Success](#tips-for-success)

---

## Workshop Overview

### Learning Objectives

By the end of this workshop, participants will be able to:

- Use Cortex LLM functions (SENTIMENT, TRANSLATE, SUMMARIZE) for text analysis
- Leverage COMPLETE function for classification, extraction, and generation tasks
- Create and query Cortex Search services for semantic search
- Implement RAG (Retrieval-Augmented Generation) patterns
- Build practical AI applications using only SQL

### Target Audience

- Data analysts who know SQL
- Data engineers working with Snowflake
- BI developers looking to add AI capabilities
- Anyone interested in AI without learning Python

**Prerequisites:** Basic SQL knowledge, familiarity with SELECT statements and JOINs

### Workshop Format

- **Duration:** 45 minutes
- **Format:** Hands-on, instructor-led
- **Style:** Live coding with explanation, participants follow along
- **Pacing:** Progressive - simple to advanced

---

## Pre-Workshop Preparation

### 1-2 Weeks Before

#### ☐ Review Materials

- [ ] Read through all three worksheets
- [ ] Review [answer keys](answer_keys/) to understand expected solutions
- [ ] Note: LLM outputs vary - answer keys show examples, not exact matches
- [ ] Familiarize yourself with alternative solutions shown in answer keys

#### ☐ Confirm Workshop Details

- [ ] Date, time, and duration confirmed
- [ ] Number of attendees confirmed (max 30 for this setup)
- [ ] Virtual or in-person format
- [ ] Recording permissions if virtual

#### ☐ Technical Setup

- [ ] Access to Snowflake account with ACCOUNTADMIN role
- [ ] Verify Cortex features enabled in your account/region
- [ ] Check region supports Cortex Search (most AWS/Azure regions do)
- [ ] Test all three worksheets end-to-end yourself
- [ ] Bookmark answer keys for quick reference during workshop

#### ☐ Communications

- [ ] Send calendar invites with Zoom/meeting link
- [ ] Share pre-workshop email (see [template](#pre-workshop-email-template))
- [ ] Confirm A/V setup if in-person

### 3-5 Days Before

#### ☐ Run Account Provisioning

**Important:** Do this 3-5 days before, not day-of!

1. Open Snowflake as ACCOUNTADMIN
2. Review [lab_setup/account-provision.sql](lab_setup/account-provision.sql)
3. **Customize:**
   - Line 76: Set your password (change from default)
   - Line 75: Adjust NUM_USERS if not 30
   - Line 28: Update comment with event name/date
4. **Run the script** (takes 2-3 minutes)
5. **Verify:**
   - All users created (check verification queries at end)
   - All schemas created
   - Test login with `CORTEXLAB01` account

#### ☐ Load Sample Data

1. Run [lab_setup/sample-data.sql](lab_setup/sample-data.sql) (takes 2-3 minutes)
2. **Verify:**
   - 4 tables created in LAB_DATA.SAMPLES
   - Cortex functions work (test queries at end of script)
   - Cortex Search service created and ACTIVE

#### ☐ Generate Credential Cards

Run the credential export query from account-provision.sql (line 169-179):

- Export to CSV or Excel
- Create PDF/print-ready format if in-person
- Prepare digital handout if virtual

#### ☐ Prepare Materials

- [ ] Clone this GitHub repo locally
- [ ] Test opening all worksheets in Snowflake web UI
- [ ] Prepare screen sharing (close unnecessary windows/tabs)
- [ ] Queue up worksheets in browser tabs
- [ ] Test your microphone/camera if virtual

### Day Before

#### ☐ Final Check

- [ ] Test login with 2-3 random lab accounts
- [ ] Verify search service is still ACTIVE
- [ ] Review timing - practice your introduction
- [ ] Prepare backup plan (what if Snowflake is down?)
- [ ] Print credentials if in-person

#### ☐ Prep Your Environment

- [ ] Close unnecessary applications
- [ ] Increase font size for screen sharing (16-18pt minimum)
- [ ] Bookmark important links
- [ ] Have this instructor guide open for reference
- [ ] Prepare water/coffee for yourself

---

## Delivery Guide

### Workshop Timeline

| Time | Duration | Activity | Notes |
|------|----------|----------|-------|
| 0:00 | 3 min | Introduction & Setup | Get everyone logged in |
| 0:03 | 15 min | Worksheet 1 | SENTIMENT, TRANSLATE, SUMMARIZE |
| 0:18 | 12 min | Worksheet 2 | CORTEX.COMPLETE |
| 0:30 | 13 min | Worksheet 3 (Core) | Cortex Search & RAG |
| 0:43 | 2 min | Wrap-up & Resources | Share continuation resources |

### Introduction (0:00-0:03) - 3 minutes

**Goals:** Welcome, context, get everyone logged in

#### Your Script

> "Welcome to the Snowflake Cortex AI Lab! My name is [name] and for the next 45 minutes, we're going to explore how to add AI capabilities to your data warehouse using just SQL.
>
> **What we'll cover:**
>
> - Text sentiment analysis and translation
> - Using LLMs for classification and extraction
> - Building semantic search and chatbots
> - All without writing a single line of Python!
>
> **Format:** I'll explain concepts, then we'll run queries together. Follow along at your own pace - all materials will be available after to catch up.
>
> **Let's get you logged in...**"

#### Login Process (2 minutes)

1. **Share credentials** (show on screen or via chat)
   - Everyone gets unique username: CORTEXLAB01-30
   - Same password for all (you set this in provisioning)

2. **Share Snowflake URL** (your account URL)

3. **Walk through login:**
   - "Enter your assigned username"
   - "Enter the password: [show password]"
   - "If prompted to change password, click 'Skip for now'"

4. **Quick orientation:**
   - "Click 'Worksheets' in left navigation"
   - "We'll be running SQL queries here"
   - "Your data is already loaded in LAB_DATA database"

**Pro Tip:** Have 1-2 assistants/helpers to troubleshoot login issues while you continue

### Worksheet 1: Cortex LLM Functions (0:03-0:18) - 15 minutes

**File:** [worksheets/worksheet-01.sql](worksheets/worksheet-01.sql)

#### Opening (1 minute)

> "Worksheet 1 covers the basic building blocks of Cortex AI. We'll analyze sentiment in customer feedback, translate between languages, and summarize long documents - all with simple SQL functions.
>
> Open the worksheet file - you can either copy from the GitHub repo or I'll share the SQL as we go."

#### Exercise 1.1: Sentiment Analysis (4 minutes)

**Teaching Points:**

- Explain: "Sentiment scores range from -1 (very negative) to +1 (very positive)"
- Real use case: "Imagine auto-flagging angry customer tickets for immediate attention"

**Demo Flow:**

1. Run STEP 1 (basic sentiment)
   - Point out: "Notice the scores - negative tickets have negative scores"
2. Run STEP 2 (categorization)
   - Highlight: "We're using CASE statements to bucket sentiment into categories"
3. Let them try STEP 3
   - "Take 30 seconds - add the WHERE clause to find negative open tickets"
   - Show solution after

**Key Quote:**
> "This is the power of Cortex - enterprise-grade AI models accessible with a simple SQL function. No API keys, no model deployment, just SQL."

#### Exercise 1.2: Translation (4 minutes)

**Teaching Points:**

- "Global companies get feedback in dozens of languages"
- "Cortex can translate between 100+ languages automatically"

**Demo Flow:**

1. Show language distribution query
2. Run translation example
   - Point out: "Look - Spanish to English, German to English, all in real-time"
3. Show nesting example
   - **This is key:** "Notice we can NEST functions - translate then analyze sentiment"

**Key Quote:**
> "You can now analyze global customer sentiment without hiring translators or managing translation APIs."

#### Exercise 1.3: Summarization (3 minutes)

**Teaching Points:**

- "Documentation is lengthy - we need executive summaries"
- "SUMMARIZE condenses while preserving key information"

**Demo Flow:**

1. Show document length query
   - "Some docs are 2,000+ characters - too long to scan quickly"
2. Run summarization example
   - Point out compression percentage
3. Quick demo of sales transcript summary

**Key Quote:**
> "Perfect for summarizing meeting notes, support tickets, call transcripts - anything with lots of text."

#### Exercise 1.4: Combining Functions (3 minutes)

**Teaching Points:**

- "Real applications combine multiple Cortex functions"
- "Common pattern: TRANSLATE → SENTIMENT → SUMMARIZE"

**Demo Flow:**

1. Run the complete multi-function query
   - Walk through: "For each ticket, we translate, analyze sentiment, and summarize"
   - Point out CASE statements avoid re-translating English
2. Show final results
   - "Now we have an international support dashboard in one query!"

**Transition:**
> "Worksheet 1 complete! We've covered the basic Cortex functions. Now let's level up with the COMPLETE function - your gateway to full LLM capabilities."

### Worksheet 2: CORTEX.COMPLETE (0:18-0:30) - 12 minutes

**File:** [worksheets/worksheet-02.sql](worksheets/worksheet-02.sql)

#### Opening (30 seconds):

> "COMPLETE gives you access to large language models like Mixtral and Llama. Unlike SENTIMENT or TRANSLATE which have one job, COMPLETE can do anything: classify, extract, generate, answer questions. The key is how you prompt it."

#### Exercise 2.1: Introduction (1 minute)

**Teaching Points:**

- "COMPLETE takes two things: a model name and a prompt"
- "Think of it like ChatGPT, but in your SQL queries"

**Demo Flow:**

1. Run the "Hello World" test
2. Show apology email generation
   - "Same function, different prompt, completely different output"

**Key Quote:**
> "The model has no idea about your specific data - you provide context in the prompt."

#### Exercise 2.2: Text Classification (3 minutes)

**Teaching Points:**

- "Classification = putting things into categories"
- "Traditional approach: write regex rules. AI approach: just ask!"

**Demo Flow:**

1. Show single ticket classification
   - Point out: "We're giving it options and asking it to pick one"
2. Show multiple tickets at once
3. Let them try urgency classification
   - "Modify the prompt to classify urgency - I'll give you 45 seconds"

**Key Quote:**
> "This scales to thousands of tickets. Your support team just got an AI assistant."

#### Exercise 2.3: Data Extraction (3 minutes)

**Teaching Points:**

- "Unstructured data contains structured information"
- "LLMs can extract specific fields from messy text"

**Demo Flow:**

1. Show action items extraction from sales call
   - "From a 30-minute transcript, we get the action items"
2. Show multiple field extraction
   - Point out structured output format
3. Quick show of feature extraction from docs

**Pro Tip:** If running short on time, skip STEP 3 and move on.

#### Exercise 2.4: Content Generation (2 minutes)

**Teaching Points:**

- "Don't just analyze - generate new content!"
- "Draft responses, create FAQs, write summaries"

**Demo Flow:**

1. Show review response generation
   - "Notice it's empathetic and professional - the prompt told it to be"
2. Quick show FAQ generation

#### Exercise 2.5: Model Comparison (1 minute - OPTIONAL)

**If time allows:**

- Show same prompt with different models
- Point out subtle differences in style

**If short on time:**
> "Exercise 2.5 compares different models - try this later to see which you prefer for your use cases."

#### Exercise 2.6: Final Example (1.5 minutes)

**Teaching Points:**

- "Real applications combine multiple Cortex functions"
- "Here's a complete ticket triage system"

**Demo Flow:**

1. Show the complete query
   - Walk through: "Translate → Sentiment → Classify → Prioritize → Suggest action"
2. Show results
   - "Five Cortex functions in one query - this is production-ready!"

**Transition:**
> "Excellent! We've mastered the COMPLETE function. Now for the grand finale - semantic search and RAG patterns."

### Worksheet 3: Cortex Search & RAG (0:30-0:43) - 13 minutes

**File:** [worksheets/worksheet-03.sql](worksheets/worksheet-03.sql)

#### Opening (30 seconds)

> "Final worksheet! We're building intelligent search systems. Instead of keyword matching like Google, we'll search by meaning. Then we'll combine search with LLMs to build systems that answer questions accurately from your documentation."

#### Exercise 3.1: Traditional vs Semantic Search (1.5 minutes)

**Teaching Points:**

- "Traditional search: exact word matching"
- "Semantic search: understanding meaning"

**Demo Flow:**

1. Show traditional search
   - "Had to think of every possible phrase someone might use"
2. Preview semantic search concept
   - "Next, we'll search with natural language"

#### Exercise 3.2: Create Search Service (2 minutes)

**Teaching Points:**

- "Search service = creates vector embeddings of your content"
- "One-time setup, then you can search instantly"

**Demo Flow:**

1. Show service creation query
   - Point out: ON content, ATTRIBUTES title/doc_type
2. Run it
   - "This takes 30-60 seconds to index"
3. Check status
   - "Wait for indexing_state = ACTIVE"

**While Waiting:**
> "While that indexes, let me explain what's happening. Cortex is reading every document, creating vector embeddings - mathematical representations of meaning - and storing them. This lets us search by similarity, not just keywords."

**Pro Tip:** If service takes too long, have a backup demo account ready where it's already created.

#### Exercise 3.3: Semantic Search (2 minutes)

**Once service is ACTIVE:**

**Demo Flow:**

1. Run semantic search for WiFi problems
   - Point out: "Look - it found the network troubleshooting doc even though query said 'WiFi' and doc says 'network'"
2. Show multiple searches
   - "Same concept, different questions, different docs returned"

**Key Quote:**
> "This is powerful for knowledge bases. Employees search 'I forgot my login' and it finds 'password reset procedures' even though the words don't match."

#### Exercise 3.4: RAG Pattern (4 minutes)

**Teaching Points:**

- **This is the most important concept:**
  - "RAG = Retrieval Augmented Generation"
  - "Problem: LLMs hallucinate - make up answers"
  - "Solution: Give them ONLY real docs to reference"

**Demo Flow:**

1. Explain the pattern visually:
   - "Step 1: Search for relevant docs (RETRIEVAL)"
   - "Step 2: Pass docs to LLM (AUGMENTATION)"
   - "Step 3: LLM answers using only those docs (GENERATION)"

2. Run the simple RAG example
   - Walk through the CTE
   - Point out: "We're literally telling it 'use ONLY this documentation'"
3. Show results
   - "Accurate answer grounded in real documentation!"

**Key Quote:**
> "This is how you build chatbots that don't make stuff up. They can only reference what you give them."

#### Exercise 3.5: Support Ticket Auto-Response (3 minutes)

**Teaching Points:**

- "Putting it all together for a real use case"
- "Incoming ticket → find relevant docs → generate response"

**Demo Flow:**

1. Run STEP 1
   - Show French ticket getting translated, relevant docs found, response generated
2. If time allows, let them try STEP 2 with different tickets

**Transition:**
> "And that's the core workshop! You've now seen the full power of Cortex AI."

#### Exercise 3.6: Final Showcase (OPTIONAL - if time)

If you have 2-3 minutes left:

- Run the final showcase query
- Point out: "All of Cortex in one query - translation, sentiment, search, RAG"

If time is tight:
> "Exercise 3.6 is the final showcase query that combines everything. Try it after the workshop!"

### Wrap-up & Next Steps (0:43-0:45) - 2 minutes

**Goals:** Inspire continued learning, share resources

#### Your Script

> "Congratulations! In 45 minutes you've learned to:
>
> - Analyze sentiment and translate languages
> - Use LLMs for classification and generation
> - Build semantic search systems
> - Implement RAG patterns for accurate AI
>
> **Continue learning:**
>
> 1. **Get your own free trial:** signup.snowflake.com - $400 in free credits!
> 2. **Run the setup:** Use self-service-setup.sql from the GitHub repo
> 3. **Try advanced exercises:** Worksheets have bonus sections you didn't see
> 4. **Build real projects:** Use your company data!
>
> **Resources I'm sharing:**
>
> - GitHub repo: [show on screen]
> - WORKSHOP_HANDOUT.md: Quick reference for everything we covered
> - SELF_GUIDED_SETUP.md: Step-by-step guide for your trial account
>
> **Questions?**"

#### Q&A (if time)

- Take 1-2 questions
- Offer to stay online/available after for more questions

#### Final Words

> "Thank you for attending! I'd love to see what you build with Cortex. Tag me on LinkedIn with #SnowflakeCortex if you create something cool.
>
> Safe travels, and happy building!"

---

## Troubleshooting

### Common Issues & Solutions

#### "I can't log in"

**Possible causes:**

1. **Wrong username** - Check they're using CORTEXLABxx not their personal account
2. **Wrong password** - Re-share the password you set
3. **Account locked** - Happens after too many failed attempts
   - Solution: Reset in Snowflake as ACCOUNTADMIN: `ALTER USER CORTEXLABxx SET PASSWORD = 'yourpassword';`

#### "Search service won't create" or "Takes too long"

**Solutions:**

1. **Check warehouse is running:** `ALTER WAREHOUSE CORTEX_LAB_WH RESUME;`
2. **Check region support:** Some regions don't have Cortex Search yet
3. **Fallback:** Skip Exercise 3.2 and use a pre-created service in your demo account

#### "Cortex function not found"

**Cause:** Account doesn't have Cortex privileges

**Solution:**

```sql
USE ROLE ACCOUNTADMIN;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE CORTEX_LAB_USER;
```

#### "Query runs forever"

**Possible causes:**

1. **Warehouse suspended** - Auto-resume should handle this, but manually: `ALTER WAREHOUSE CORTEX_LAB_WH RESUME;`
2. **Large LISTAGG** - If trying to aggregate too much text, add LIMIT
3. **Network issues** - Check participant's connection

#### "Different results than expected"

**This is normal!**

- LLMs are non-deterministic
- Results will vary slightly between runs
- Point this out: "Notice your answer might be worded differently than mine - that's expected with AI!"

### Technical Backup Plans

#### If Snowflake is Down (Rare but possible)

**Option 1: Pivot to Theory**

- Walk through slides explaining Cortex concepts
- Show pre-recorded demo video
- Share materials for self-guided completion later

**Option 2: Use Personal Account**

- Have materials loaded in your personal account as backup
- Do live demo, participants follow along by watching
- They complete hands-on portion later

**Option 3: Reschedule**

- If total outage, reschedule for next day/week
- Communicate clearly with participants

---

## Post-Workshop

### Immediately After (Within 1 hour)

#### ☐ Follow-up Email

Send participants:

- Link to GitHub repository
- Link to WORKSHOP_HANDOUT.md
- Link to self-service-setup.sql
- Trial signup link: signup.snowflake.com
- Your contact info for questions
- Survey/feedback form (if you have one)

**See:** [Post-Workshop Email Template](#post-workshop-email-template) below

#### ☐ Share Recording (if applicable)

- Upload to YouTube/company portal
- Share link with participants
- Make publicly available if appropriate

### Within 7 Days

#### ☐ Gather Feedback

- Review any surveys sent
- Note common questions/issues for next time
- Identify topics that need more/less time

#### ☐ Update Materials

- Fix any typos/errors discovered during workshop
- Add clarifications for confusing parts
- Update this instructor guide with lessons learned

### 7-14 Days After

#### ☐ Account Cleanup

Once sufficient time has passed for participants to set up their own accounts:

1. Run [lab_setup/account-cleanup.sql](lab_setup/account-cleanup.sql)
2. Verify all lab accounts deleted
3. Optional: Keep LAB_DATA database for next workshop
4. Document cleanup date

**Note:** Don't rush cleanup - give participants at least 7 days to transition to their own accounts.

---

## Tips for Success

### Before Workshop

**1. Practice, Practice, Practice**

- Run through entire workshop 2-3 times solo
- Practice explaining concepts out loud
- Time yourself to ensure you stay on schedule

**2. Prepare Your Demo Environment**

- Increase font size (16-18pt minimum)
- Close unnecessary applications
- Use full-screen mode for Snowflake
- Have GitHub repo open in another tab

**3. Test Your Setup**

- Screen sharing quality
- Audio levels
- Backup internet connection (mobile hotspot)
- Have phone number for Zoom tech support

### During Workshop

**1. Pacing**

- Watch the clock every 10 minutes
- If running behind, skip optional exercises
- Better to finish strong than rush the ending
- Have "fast track" mentally planned

**2. Engagement**

- Ask for confirmation: "Everyone with me?"
- Watch chat for questions in virtual sessions
- Call on people by name occasionally
- Celebrate wins: "Great question!" "Exactly right!"

**3. Handling Questions**

- Answer quick ones inline
- Defer complex questions: "Great question - let's discuss after"
- Don't let one person dominate Q&A
- If you don't know: "I'm not sure, but I'll find out and follow up"

**4. Technical Issues**

- Stay calm - technical issues happen
- Have an assistant help while you continue
- Don't spend >2 minutes troubleshooting one person's issue
- Offer to help them individually after

**5. Energy Management**

- Vary your tone/pace to maintain energy
- Stand up if in-person (more energy)
- Take a 30-second pause mid-way (drink water)
- Show genuine enthusiasm for the content

### Virtual-Specific Tips

**1. Setup**

- Two monitors ideal: one for presenting, one for notes/chat
- Gallery view to see participants
- Spotlight your screen when sharing
- Pin yourself when not sharing

**2. Engagement**

- Ask people to use reactions (👍 when they complete a step)
- Monitor chat actively for questions
- Call on people by name from participant list
- Do mic/video checks at start

**3. Recording**

- Announce recording at start
- Pause recording if discussing sensitive info
- Post-edit to remove dead time/issues

### In-Person Tips

**1. Room Setup**

- Arrive 30 min early
- Test projector/screen
- Ensure WiFi works
- Have power strips for participants
- Arrange room for easy movement

**2. Engagement**

- Walk around room
- Check participants' screens
- Eye contact with different sections
- Use whiteboard for concepts

**3. Materials**

- Print credential cards
- Bring USB drives with materials as backup
- Have QR code for GitHub repo

### Language & Delivery

**Do's:**

- Use plain language, avoid jargon
- Explain acronyms: "RAG - Retrieval Augmented Generation"
- Use analogies: "Think of vector embeddings like GPS coordinates for text"
- Repeat key points
- Summarize after each section

**Don'ts:**

- Don't say "This is easy" (it's not for everyone)
- Don't rush through slides
- Don't skip errors - acknowledge and fix
- Don't assume everyone knows SQL equally
- Don't bash competing tools/products

### Handling Different Skill Levels

**For Beginners:**

- Explain SQL concepts briefly when needed
- Show, don't just tell
- Encourage questions
- Pair them with experienced participants

**For Advanced Users:**

- Point them to advanced exercises
- Challenge them with optional TODOs
- Ask them to help neighbors
- Share GitHub for deeper exploration

### Common Mistakes to Avoid

1. ❌ **Going off-script too much** - Tangents eat your 45 minutes
2. ❌ **Skipping verification steps** - Always check query results
3. ❌ **Not watching the clock** - Easy to overrun
4. ❌ **Assuming everyone is following** - Check in regularly
5. ❌ **Reading slides verbatim** - Explain in your own words
6. ❌ **Not testing beforehand** - Murphy's law applies
7. ❌ **Forgetting to share resources** - They need the GitHub link!

### What Makes a Great Workshop

✅ Clear learning objectives
✅ Hands-on practice
✅ Real-world examples
✅ Good pacing
✅ Helpful troubleshooting
✅ Resources to continue learning
✅ Enthusiastic instructor
✅ Actionable takeaways

---

## Email Templates

### Pre-Workshop Email Template

```text
Subject: Snowflake Cortex AI Lab - Tomorrow at [TIME]!

Hi [Participant Name],

Looking forward to seeing you tomorrow for the Snowflake Cortex AI Lab!

📅 When: [Date] at [Time] [Timezone]
🔗 Join: [Meeting Link]
⏱️ Duration: 45 minutes

What to Expect:
You'll learn to add AI capabilities to Snowflake using just SQL - no Python required! We'll cover sentiment analysis, translation, LLMs, and semantic search.

What You Need:
✅ Web browser (Chrome/Firefox recommended)
✅ Nothing to install - it's all in Snowflake!
✅ Lab credentials will be provided during session

Pre-Workshop (Optional):
- Familiarize yourself with SQL basics
- Sign up for Snowflake trial if you want to continue after: signup.snowflake.com

Questions? Reply to this email.

See you tomorrow!
[Your Name]
```

### Post-Workshop Email Template

```
Subject: Snowflake Cortex AI Lab - Resources & Next Steps

Hi [Participant Name],

Thank you for attending the Snowflake Cortex AI Lab today! 🎉

Continue Your Learning:

1️⃣ Get Your FREE Trial
Sign up: https://signup.snowflake.com ($400 credits included)

2️⃣ Set Up in 3 Minutes
Use this setup script: [link to self-service-setup.sql]
Step-by-step guide: [link to SELF_GUIDED_SETUP.md]

3️⃣ Access All Materials
GitHub Repository: [your-repo-link]
Workshop Handout: [link to WORKSHOP_HANDOUT.md]
Recording (if available): [link]

What We Covered:
✓ SENTIMENT, TRANSLATE, SUMMARIZE functions
✓ CORTEX.COMPLETE for LLM tasks
✓ Cortex Search for semantic search
✓ RAG patterns for accurate AI

Try Next:
- Complete the advanced exercises (Worksheet 3, 3.7-3.10)
- Build a chatbot on your company docs
- Analyze your own data with Cortex

Questions?
Reply to this email or open a GitHub issue.

Share What You Build:
Tag me on LinkedIn with #SnowflakeCortex - I'd love to see what you create!

Happy building! 🚀
[Your Name]
[Your LinkedIn]
[Your Email]
```

---

## Additional Resources for Instructors

### Recommended Reading

Before teaching this workshop, familiarize yourself with:

- [Snowflake Cortex Documentation](https://docs.snowflake.com/cortex)
- [RAG Pattern Best Practices](https://docs.snowflake.com/cortex/rag)
- [Prompt Engineering Guide](https://www.promptingguide.ai/)

### Community

- Join Snowflake Community for instructor discussions
- Connect with other Cortex workshop instructors
- Share your experience improving these materials

### Continuous Improvement

This is a living guide! After each workshop:

1. Note what worked well
2. Identify what could improve
3. Submit pull requests to improve materials
4. Share feedback via GitHub issues

---

## Appendix: Quick Reference

### Key Commands

```sql
-- Grant Cortex privileges
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE CORTEX_LAB_USER;

-- Check search service status
DESCRIBE CORTEX SEARCH SERVICE PRODUCT_DOCS_SEARCH;

-- Resume warehouse
ALTER WAREHOUSE CORTEX_LAB_WH RESUME;

-- Reset user password
ALTER USER CORTEXLAB01 SET PASSWORD = 'yourpassword';
```

### Time Checkpoint Reference

- 0:03 - Finished introduction
- 0:10 - Midway through Worksheet 1
- 0:18 - Starting Worksheet 2
- 0:30 - Starting Worksheet 3
- 0:40 - Should be at Exercise 3.4 or 3.5
- 0:43 - Start wrap-up

### Fast Track (If Running Behind)

**Cut these exercises if short on time:**

1. Worksheet 1, Exercise 1.4 Step 2 (review analysis)
2. Worksheet 2, Exercise 2.4 Step 2 (FAQ generation)
3. Worksheet 2, Exercise 2.5 (model comparison)
4. Worksheet 3, Exercise 3.6 (final showcase)

**Never skip these:**

- Worksheet 1: 1.1, 1.2, 1.3
- Worksheet 2: 2.2, 2.3
- Worksheet 3: 3.2, 3.4 (RAG is critical!)

---

## Final Checklist

### Day of Workshop

**30 Minutes Before:**

- [ ] Join meeting/arrive at room
- [ ] Test audio/video
- [ ] Open all materials
- [ ] Verify lab accounts work
- [ ] Take a deep breath!

**During Workshop:**

- [ ] Record (if applicable)
- [ ] Share screen
- [ ] Watch clock
- [ ] Monitor chat/questions
- [ ] Have fun!

**After Workshop:**

- [ ] Stop recording
- [ ] Answer lingering questions
- [ ] Send follow-up email
- [ ] Note lessons learned

---

**Good luck with your workshop! You've got this! 🚀**

*Remember: The best workshops are where both the instructor and participants are learning and having fun. Enjoy the experience!*

---

*This guide was created for the Snowflake Cortex AI Lab. Contributions and improvements welcome via pull request.*
