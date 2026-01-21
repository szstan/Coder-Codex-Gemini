# Contract Quick Reference

> **相关文档**：
> - [入门指南](contracts/contract_quickstart.md) - 何时需要 Contract
> - [质量标准](contract_quality_standards.md) - Contract 验收标准
> - [空白模板](contracts/contract_template.md) - 创建新 Contract

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
