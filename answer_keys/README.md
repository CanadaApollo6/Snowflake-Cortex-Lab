# Answer Keys

This folder contains complete solutions and explanations for all TODO exercises in the Snowflake Cortex AI Lab worksheets.

## Purpose

These answer keys are designed for:

- **Self-learners:** Verify your solutions and understand alternative approaches
- **Instructors:** Quick reference during workshops and for creating teaching materials
- **Reviewers:** Understand expected outcomes and learning objectives

## Files

| File | Worksheet | Description |
|------|-----------|-------------|
| [worksheet-01-answers.sql](worksheet-01-answers.sql) | Worksheet 1 | Solutions for SENTIMENT, TRANSLATE, SUMMARIZE exercises |
| [worksheet-02-answers.sql](worksheet-02-answers.sql) | Worksheet 2 | Solutions for CORTEX.COMPLETE exercises |
| [worksheet-03-answers.sql](worksheet-03-answers.sql) | Worksheet 3 | Solutions for Cortex Search and RAG exercises |

## How to Use

### For Self-Learners

1. **Try first, check second:** Attempt the TODO exercises on your own before looking at answers
2. **Compare approaches:** Your solution may differ but still be correct - LLMs are non-deterministic
3. **Read explanations:** Each answer includes detailed explanations of why it works
4. **Learn patterns:** Notice the patterns and techniques used across solutions

### For Instructors

1. **Preparation:** Review answer keys before teaching to anticipate questions
2. **During workshop:** Quick reference if participants get stuck
3. **Grading:** If running as a course, use these as grading rubrics
4. **Adaptation:** Feel free to modify for your specific audience

## Important Notes

### About LLM Outputs

**Your results WILL differ from the examples shown** - this is normal and expected!

Large Language Models (LLMs) are **non-deterministic**, meaning:
- Same prompt can produce different outputs each time
- Different wording is completely acceptable
- Focus on whether the output is:
  - ✅ Relevant to the prompt
  - ✅ Accurate based on input data
  - ✅ Properly formatted as requested

**Example:**
```
Query: "Classify this ticket urgency: high, medium, or low"

Valid outputs:
- "high"           ✅ Correct
- "High"           ✅ Correct
- " high "         ✅ Correct (has whitespace but contains answer)
- "The urgency is high" ✅ Correct (contains answer)

Invalid outputs:
- "urgent"         ❌ Wrong - didn't use provided options
- "3"              ❌ Wrong - used number instead of word
- "Error"          ❌ Wrong - function failed
```

### About Search Scores

Cortex Search scores may vary slightly between runs due to:
- Index updates
- Minor changes in the vector embeddings
- Snowflake system optimizations

**What matters:** Relevant documents are returned with high scores, not the exact score values.

## What Each Answer Key Contains

Each answer key includes:

1. **Complete SQL Solutions** - Copy-paste ready code
2. **Explanations** - Why this approach works
3. **Expected Results** - What output you should see (approximately)
4. **Key Insights** - Learning points for each exercise
5. **Alternative Approaches** - Different ways to solve the same problem
6. **Common Pitfalls** - Mistakes to avoid
7. **Production Tips** - How to use these patterns in real applications

## Alternative Solutions

For many exercises, **multiple correct solutions exist**. The answer keys show:
- Primary solution (most straightforward)
- Alternative approaches (may be more efficient or readable)
- Different prompt styles that work

**All valid approaches are correct** - choose based on your use case.

## When Solutions Don't Match

If your solution differs from the answer key:

### ✅ Your solution is likely correct if:
- It produces relevant output
- The logic is sound
- It follows SQL best practices
- The LLM response addresses the prompt

### ⚠️ Double-check if:
- You get errors
- Output is completely irrelevant
- Missing required components (like translation or filtering)
- Results don't make logical sense

### 🆘 Need help?
- Re-read the exercise instructions
- Check your SQL syntax
- Verify Cortex functions are spelled correctly
- Look at the explanation in the answer key
- Open an issue on GitHub if still stuck

## Instructor Tips

### During Workshop

**Don't just show the answer!** Instead:
1. Give hints: "Remember we need to filter WHERE status = 'open'"
2. Guide thinking: "What function analyzes emotion in text?"
3. Show pattern: "This is similar to Exercise 1.1"
4. Let them struggle a bit - learning happens through problem-solving

**When to show answers:**
- After giving participants time to try (2-3 minutes)
- When entire group is stuck
- As a "let's review this together" moment

### Teaching Philosophy

These answer keys are designed to support **discovery-based learning**:
- Participants try first
- Make mistakes (that's good!)
- Learn from attempts
- Compare with answer key
- Understand why it works

## Contributing

Found a better solution? See an error? Have an alternative approach?

**Contributions welcome!**
- Open a pull request with improvements
- Suggest additional explanations
- Share real-world variations

## License

Same as the main repository: Apache License 2.0

---

**Remember:** The goal isn't perfect answers - it's understanding the concepts and being able to apply them to your own data!
