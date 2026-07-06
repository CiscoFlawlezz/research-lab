---
title: AI Research Workflow
tags:
  - ai
  - research
  - scientific-method
  - reproducibility
  - workflow
---

# AI Research Workflow

## Overview

Artificial intelligence is a powerful research assistant, not a replacement for scientific reasoning. The researcher remains responsible for asking meaningful questions, designing experiments, interpreting evidence, identifying limitations, and making final conclusions.

The goal is to use AI to reduce repetitive cognitive work while preserving rigorous human judgment.

---

# Guiding Principle

> AI accelerates research.
> Humans provide understanding.

Every important scientific claim should ultimately be supported by primary evidence rather than generated text.

---

# Where AI Excels

## Literature Exploration

AI can:

- summarize papers
- compare multiple publications
- explain unfamiliar concepts
- identify recurring themes
- extract methods
- generate reading lists
- identify influential authors
- organize references
- convert dense writing into plain language

Useful prompt:

> Summarize this paper including objective, methodology, assumptions, limitations, and future work.

---

## Brainstorming

AI is useful for:

- hypothesis generation
- identifying alternative explanations
- suggesting experimental controls
- identifying missing variables
- proposing sensitivity analyses
- generating research questions

Example:

> What assumptions does this experimental design make?

---

## Programming

AI performs well at:

- writing boilerplate code
- debugging
- explaining algorithms
- translating between languages
- creating unit tests
- documenting code
- improving readability
- optimizing performance
- generating plotting scripts

Always review generated code before use.

---

## Data Processing

AI can assist with:

- parsing datasets
- writing analysis pipelines
- cleaning data
- generating visualizations
- creating statistical summaries
- identifying outliers
- suggesting analysis methods

---

## Scientific Writing

AI is valuable for:

- improving grammar
- restructuring paragraphs
- polishing clarity
- generating outlines
- formatting citations
- producing abstracts
- drafting documentation
- converting notes into reports

Authors remain responsible for factual accuracy.

---

## Documentation

AI can automatically generate:

- README files
- API documentation
- laboratory protocols
- experiment summaries
- changelogs
- meeting notes
- project documentation

---

# AI Weaknesses

AI systems have important limitations.

## Hallucinations

AI may:

- invent references
- fabricate quotations
- create nonexistent equations
- generate fake datasets
- misrepresent published findings
- confuse similar papers
- cite imaginary authors

Never assume a citation exists because AI generated it.

---

## Limited Scientific Judgment

AI does not truly understand:

- causality
- experimental validity
- scientific novelty
- research significance
- ethical implications

It predicts plausible language rather than reasoning like a scientist.

---

## Overconfidence

Incorrect answers are often presented confidently.

Confidence should never be mistaken for correctness.

---

## Inconsistent Outputs

Repeated prompts may produce different:

- explanations
- equations
- code
- references
- recommendations

Critical workflows should therefore be deterministic whenever possible.

---

## Hidden Assumptions

AI frequently fills missing information with plausible guesses.

Always specify:

- assumptions
- constraints
- domain
- dataset
- objectives

---

# Preventing Hallucinations

## Ask for Uncertainty

Instead of asking:

> Explain this result.

Prefer:

> What parts of this answer are uncertain?

---

## Request Sources

Ask AI to distinguish:

- established facts
- assumptions
- speculation
- hypotheses

---

## Verify Every Citation

Before citing any paper:

- locate the original publication
- confirm DOI
- verify authors
- verify publication year
- read the original paper

Never cite AI-generated references without verification.

---

## Separate Facts From Interpretation

Maintain distinct sections for:

- observations
- evidence
- interpretation
- speculation

---

## Avoid Unsupported Numerical Claims

All reported:

- p-values
- confidence intervals
- effect sizes
- sample sizes

should come directly from verified analyses.

---

# Verification Workflow

```text
Research Question
        │
        ▼
Literature Search
        │
        ▼
AI Summary
        │
        ▼
Read Original Papers
        │
        ▼
Extract Evidence
        │
        ▼
Independent Analysis
        │
        ▼
AI Editing
        │
        ▼
Human Verification
        │
        ▼
Publication
```

Every important statement should trace back to a primary source.

---

# Literature Review Assistance

Recommended workflow:

1. Search databases.
2. Download papers.
3. Read abstracts.
4. Use AI to summarize.
5. Read methods.
6. Read results.
7. Verify conclusions.
8. Compare multiple studies.
9. Build synthesis tables.
10. Write literature review manually with AI editing support.

Example prompts:

- Summarize methodology.
- Compare these five papers.
- Identify conflicting conclusions.
- Extract experimental assumptions.
- List unresolved questions.

---

# Coding Assistance

AI is excellent for repetitive programming tasks.

Typical workflow:

Problem

↓

Human designs algorithm

↓

AI writes implementation

↓

Human reviews logic

↓

AI generates tests

↓

Human validates results

↓

Version control

↓

Reproducible publication

Recommended uses:

- scripting
- plotting
- automation
- debugging
- optimization
- documentation
- testing

Avoid blindly executing generated code.

---

# Documentation Generation

AI can generate documentation from:

- notebooks
- code
- experiment logs
- commit history
- laboratory notes

Useful outputs include:

## Project README

- objectives
- installation
- datasets
- workflow
- dependencies

## Experiment Documentation

Include:

- hypothesis
- methods
- parameters
- software versions
- outputs
- interpretation

## API Documentation

Generate:

- function descriptions
- parameter documentation
- examples
- return values

---

# Maintaining Reproducibility

Every project should include:

## Version Control

Track:

- code
- notebooks
- documentation
- figures

---

## Environment Management

Record:

- operating system
- package versions
- compiler versions
- hardware
- random seeds

---

## Data Provenance

Document:

- source
- preprocessing
- filtering
- exclusions
- transformations

---

## Analysis Pipelines

Automate:

- preprocessing
- analysis
- figure generation
- statistical testing

Avoid manual editing whenever possible.

---

## Experiment Logs

Maintain records of:

- parameter changes
- failed experiments
- successful experiments
- observations
- decisions

---

## Random Seeds

Record seeds for:

- simulations
- optimization
- machine learning
- sampling

This improves reproducibility.

---

## Prompt Logging

When AI contributes substantially:

Record:

- model
- date
- prompts
- generated outputs
- modifications
- verification process

This creates transparency.

---

# Recommended Human Responsibilities

Humans should always retain responsibility for:

- research questions
- experimental design
- ethical decisions
- interpretation
- statistical reasoning
- publication decisions
- final conclusions

---

# Example Daily Workflow

```text
Read Papers
      │
      ▼
AI Summaries
      │
      ▼
Human Review
      │
      ▼
Generate Ideas
      │
      ▼
Design Experiment
      │
      ▼
AI Code Assistance
      │
      ▼
Run Analysis
      │
      ▼
Verify Results
      │
      ▼
AI Documentation
      │
      ▼
Final Human Review
```

---

# Best Practices Checklist

- [ ] Read original papers
- [ ] Verify every citation
- [ ] Review all generated code
- [ ] Validate statistical analyses
- [ ] Keep experiment logs
- [ ] Record software versions
- [ ] Track prompts when AI contributes substantially
- [ ] Separate evidence from interpretation
- [ ] Use version control
- [ ] Preserve reproducible workflows
- [ ] Treat AI as an assistant rather than an authority

---

# Suggested Internal Links

- [[Scientific Method]]
- [[Research Workflow]]
- [[Literature Review]]
- [[Critical Thinking]]
- [[Experimental Design]]
- [[Statistics]]
- [[Data Analysis]]
- [[Research Notes]]
- [[Reproducible Research]]
- [[Version Control]]
- [[Git]]
- [[Python]]
- [[Jupyter Notebooks]]
- [[Machine Learning]]
- [[Prompt Engineering]]
- [[Knowledge Management]]
- [[Reference Management]]
- [[Academic Writing]]
- [[Open Science]]
- [[Research Integrity]]
```