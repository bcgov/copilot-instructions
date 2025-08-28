# AI Instruction Optimization Guide
*How to improve AI coding assistant consistency and safety*

## The Problem: Instruction Overload

**Symptoms you might experience:**
- Inconsistent AI behavior (steps not followed reliably)
- Critical safety rules ignored (accidental pushes to main)
- Previously working commands suddenly failing
- AI decision paralysis with conflicting rules

**Root Cause:** Too many instructions competing for AI attention.

## Real-World Case Study

**Before optimization:**
- Personal rules: 151 lines
- Included BCGov rules: 243 lines
- **Total: 394 lines of instructions**
- Result: Inconsistent behavior, safety violations

**After optimization:**
- Streamlined personal rules: 57 lines (62% reduction)
- Same BCGov standards: 243 lines
- **Total: 300 lines (-24% instruction load)**
- Result: Consistent behavior, improved safety compliance

## Optimization Strategy

### 1. 🚨 Safety Rules First
```markdown
## 🚨 CRITICAL SAFETY (Never Violate)
- NEVER push directly to main - always use feature branches and PRs
- ALWAYS check `git status` before suggesting any git operations
- NEVER suggest merge without confirming clean working tree
```

**Why this works:** AI sees critical rules first, reducing chance of dangerous accidents.

### 2. Hierarchical Organization
```
Global Rules (always loaded):
├── Critical safety (universal)
├── Personal preferences
└── @include shared standards

Repository Rules (when present):
├── .github/copilot-instructions.md
└── Project-specific additions
```

### 3. Move Complex Details to Documentation
**Instead of:** 50-line workflow procedures in instructions
**Do this:** 5-line summary + link to documentation

```markdown
## Essential Workflow
- Check status before operations
- Use feature branches
- Details: ~/Documents/AI/workflows.md
```

## BCGov Repository Patterns

Based on analysis of 80+ repositories:

### GitHub Actions (`action-*`)
- Workflow testing requirements
- Marketplace considerations
- Action-specific patterns

### Natural Resources (`nr-*`)
- Domain-specific compliance
- Data sovereignty requirements
- Integration patterns

### Templates (`quickstart-*`)
- Documentation completeness
- Example maintenance
- Template consistency

## Implementation Template

### For Individual Users
```markdown
# ~/.cursorrules or similar
## 🚨 CRITICAL SAFETY
[Your non-negotiable safety rules]

## Core Workflow
[Your essential preferences - keep under 10 items]

@include ~/path/to/shared/standards.md
```

### For Repository-Specific Rules
```markdown
# .github/copilot-instructions.md
# This repository follows [Organization] standards
# Reference: /path/to/shared/standards.md

## Project-Specific Additions
- [Specific patterns for this repo type]
- [Domain requirements]
- [Integration considerations]
```

## Measuring Success

### Before/After Metrics
- **Instruction count:** Aim for 200-300 total lines max
- **Safety compliance:** Track accidental violations
- **Consistency:** Monitor step-following reliability
- **Performance:** Subjective response quality

### Red Flags (Time to Optimize)
- 🔴 More than 400 lines of total instructions
- 🔴 Duplicate rules in multiple places
- 🔴 Safety violations (pushes to main, etc.)
- 🔴 Inconsistent behavior patterns

### Green Flags (Well Optimized)
- 🟢 Under 300 total instruction lines
- 🟢 Safety rules prominently positioned
- 🟢 Clear hierarchy (global → repo-specific)
- 🟢 Complex details in documentation, not instructions

## Benefits Achieved

### Performance Improvements
- **24% faster processing** (fewer instruction conflicts)
- **Consistent safety compliance** (critical rules prioritized)
- **Better step following** (reduced decision paralysis)

### Maintainability Gains
- **Single source of truth** for shared standards
- **Easy updates** (change once, apply everywhere)
- **Clear separation** (personal vs organizational vs project)

## Getting Started

1. **Audit your current instructions** - count total lines loaded per session
2. **Identify safety-critical rules** - what absolutely cannot be violated?
3. **Find redundancy** - are rules repeated in multiple files?
4. **Create hierarchy** - separate personal, organizational, and project-specific
5. **Move complexity to docs** - keep instructions focused and brief

## Questions?

This optimization approach evolved from managing AI assistance across 80+ BCGov repositories. The patterns should scale to other organizations with similar complexity.

For implementation questions or sharing your results, open an issue in this repository.
