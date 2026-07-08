---
title: Prompt Library
tags:
  - prompts
  - ai
  - research
  - productivity
  - obsidian
---

# Prompt Library

## Overview

A prompt library is a collection of reusable instructions that help produce consistent, high-quality AI outputs across research, software development, and documentation tasks.

Rather than writing new prompts from scratch, maintain a curated set of templates that can be adapted to each project. Good prompts improve consistency, reduce ambiguity, and make AI-assisted workflows easier to reproduce.

---

# Principles of Effective Prompt Design

## Define the Goal

Clearly state the desired outcome.

**Instead of:**

> Explain machine learning.

**Use:**

> Explain the role of machine learning in this project, focusing on supervised learning, assumptions, limitations, and practical applications.

---

## Provide Context

Include relevant information such as:

- project objectives
- research domain
- target audience
- available data
- constraints
- assumptions
- definitions

The more relevant context provided, the more useful the response is likely to be.

---

## Specify the Output Format

Describe exactly how the response should be organized.

Examples:

- bullet list
- Markdown
- table
- executive summary
- numbered workflow
- JSON
- Obsidian note
- code block

---

## Encourage Critical Evaluation

Ask the AI to identify uncertainty, assumptions, trade-offs, or alternative interpretations rather than only producing a direct answer.

Useful additions include:

- Identify weaknesses.
- List assumptions.
- Highlight missing information.
- Suggest alternative approaches.
- Explain confidence level.

---

## Iterate

Complex work is usually best completed over multiple prompts.

Typical workflow:

1. Generate ideas
2. Refine structure
3. Expand details
4. Verify accuracy
5. Produce final documentation

---

# Reusable Prompt Patterns

## Literature Review

```text
Act as a research assistant.

Summarize the following paper.

Include:

- research objective
- background
- methodology
- datasets
- experimental design
- statistical methods
- key findings
- assumptions
- limitations
- future work
- important terminology

Then compare it with related work and identify unanswered research questions.
```

---

## Statistical Analysis

```text
Act as a statistician.

Review the following experiment.

Identify:

- variables
- hypotheses
- assumptions
- appropriate statistical tests
- possible sources of bias
- effect sizes
- confidence intervals
- interpretation of results

Explain why each statistical method is appropriate.
```

---

## Code Review

```text
Review the following code.

Evaluate:

- correctness
- readability
- maintainability
- performance
- security
- edge cases
- error handling
- documentation
- testing opportunities

Provide concrete improvement suggestions and explain the reasoning behind each recommendation.
```

---

## Architecture Discussions

```text
Act as a senior software architect.

Evaluate this system design.

Discuss:

- scalability
- modularity
- coupling
- cohesion
- maintainability
- deployment
- testing strategy
- security
- performance
- future extensibility

Compare alternative architectures and explain their trade-offs.
```

---

## Documentation

```text
Generate professional Markdown documentation.

Include:

- overview
- objectives
- prerequisites
- installation
- configuration
- workflow
- examples
- troubleshooting
- references
- related notes

Use clear headings and concise explanations.
```

---

## Experiment Design

```text
Help design a scientific experiment.

Include:

- research question
- hypothesis
- variables
- controls
- assumptions
- methodology
- required data
- sample size considerations
- statistical analysis plan
- possible sources of bias
- reproducibility considerations
- expected outcomes
```

---

## Feature Brainstorming

```text
Brainstorm new features for the following project.

For each feature include:

- description
- user value
- implementation difficulty
- technical dependencies
- risks
- estimated impact
- possible future improvements

Organize ideas by priority.
```

---

## Debugging

```text
Help debug the following issue.

Analyze:

- probable root causes
- assumptions
- diagnostic steps
- logging improvements
- testing strategy
- possible fixes
- performance implications

Explain your reasoning before proposing a solution.
```

---

## Obsidian Note Generation

```text
Create a complete Obsidian Markdown note.

Include:

- YAML front matter
- overview
- detailed explanations
- diagrams when appropriate
- callout blocks
- tables
- examples
- checklist
- glossary
- related concepts
- suggested internal links

Use clear Markdown formatting suitable for long-term knowledge management.
```

---

# Prompt Construction Template

Use the following framework when creating new prompts.

```text
Role:
Who should the AI act as?

Objective:
What should be accomplished?

Context:
What background information is required?

Inputs:
What information is provided?

Constraints:
What limitations should be respected?

Output Format:
How should the response be organized?

Evaluation:
How should uncertainty, assumptions, or limitations be handled?
```

---

# Maintaining a Prompt Library

Review prompts regularly and refine them based on results.

Good practices include:

- remove outdated prompts
- merge duplicates
- record successful variations
- note common failure modes
- standardize formatting
- version important prompts
- organize prompts by topic
- store reusable examples

---

# Best Practices

- Start with a clear objective.
- Provide sufficient context.
- Request structured outputs.
- Ask for assumptions and limitations.
- Encourage critical analysis.
- Break large tasks into smaller prompts.
- Verify important factual claims independently.
- Treat AI output as a draft rather than a final authority.
- Reuse and improve prompts over time.
- Document prompt changes for reproducibility.

---

# Suggested Internal Links

- [[AI Research Workflow]]
- [[Prompt Engineering]]
- [[Literature Review]]
- [[Scientific Method]]
- [[Critical Thinking]]
- [[Research Workflow]]
- [[Experimental Design]]
- [[Statistics]]
- [[Data Analysis]]
- [[Software Architecture]]
- [[Code Review]]
- [[Debugging]]
- [[Documentation]]
- [[Knowledge Management]]
- [[Obsidian]]
- [[Research Notes]]
- [[Reproducible Research]]
- [[Machine Learning]]
- [[Git]]
- [[Version Control]]
```