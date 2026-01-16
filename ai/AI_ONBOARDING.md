# AI Onboarding (Local Workflow)

This project uses a local, contract-driven AI workflow.

## Roles
- Claude: Architect / Planner
- Implementer (Zhipu / GLM / Human): Executes code changes
- Codex: Independent reviewer and quality gate

## Source of Truth
- `ai/contracts/current.md` is the single source of truth
  for the current change.

## Core Principle
Engineering judgment is made first, then frozen into a contract.
Implementation and review must follow the contract strictly.

## Daily Flow
1) Plan
   - Use `ai/claude_architect.md`
   - Output a finalized Implementation Contract
2) Implement
   - Follow `ai/contracts/current.md`
   - Follow `ai/implementer_guardrails.md`
3) Review
   - Provide Git diff
   - Review against `ai/contracts/current.md`
   - Apply review gate rules
4) Fix or revise contract, then commit

## Important
- Chat history is never a source of truth.
- If it is not written in the contract, it is not allowed.
