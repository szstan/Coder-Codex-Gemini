# Implementation Contract Checklist

> **相关文档**：
> - [入门指南](contracts/contract_quickstart.md) - 何时需要 Contract
> - [编写原则](contract_principles.md) - 如何写好 Contract
> - [空白模板](contracts/contract_template.md) - 创建新 Contract

Use this checklist before implementation and before review.

## Form Rules (Hard)
- [ ] Contract contains only decisions and constraints
- [ ] No chat history or discussion text
- [ ] Performance trigger is YES or NO (never "maybe")

## Scope
- [ ] Files/modules to be touched are listed
- [ ] Explicit out-of-scope areas are listed

## Intent
- [ ] One primary responsibility
- [ ] Clear success criteria

## Evolution Safety
- [ ] Must-not-change behaviors are explicit
- [ ] Backward compatibility assumptions are stated

## Performance Gate
If YES:
- [ ] Reason for trigger
- [ ] Expected complexity O(?)
- [ ] Scale assumption n ≈ ?
- [ ] Bottleneck (CPU / Memory / IO)
If NO:
- [ ] Explicitly states default to simplicity

## Forbidden Patterns
- [ ] Forbidden optimizations listed (cache, concurrency, globals)
- [ ] Forbidden dependencies or abstractions listed

## Observability & Errors
- [ ] Required logs/events specified
- [ ] Required error context specified

## Testing
- [ ] Unit tests required
- [ ] Failure-path tests required
- [ ] Integration tests specified if needed

## Open Questions
- [ ] Uncertainties listed only here
