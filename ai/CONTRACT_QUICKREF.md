# Contract Quick Reference

A good Implementation Contract is:
- Short
- Executable
- Reviewable

## Must-Have Sections
- Scope
- Intent
- Must-not-change behaviors
- Performance trigger (YES / NO)
- Forbidden patterns
- Tests

## Common Mistakes
- Writing philosophy instead of decisions
- Leaving performance as "maybe"
- Forgetting failure-path tests
- Expanding scope implicitly

## Size Guide
- Target: 10–30 lines of filled content
- If >1 page, you're writing a design doc, not a contract

## Rule of Thumb
If it cannot be checked during review,
it does not belong in the contract.
