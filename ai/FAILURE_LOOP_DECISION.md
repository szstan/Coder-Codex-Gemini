# Failure Loop Decision Guide

When review produces Blocking issues, decide the fix target.

## Golden Rule
- Code violates contract → Fix code
- Contract is wrong or incomplete → Fix contract

## Fix Code When
- Scope exceeded
- Must-not-change behavior broken
- Forbidden pattern introduced
- Required tests/logs missing
- Performance gate violated

## Fix Contract When
- Requirements are contradictory
- New constraints are discovered
- Performance trigger decision was wrong
- Scope legitimately changes

## Process
1) Decide code vs contract
2) Fix the chosen target
3) Re-run review
4) Commit only when clean

Never bypass the review gate.
