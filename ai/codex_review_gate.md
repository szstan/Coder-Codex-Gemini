Review Rules (Binding)

Inputs:
- Git diff
- ai/contracts/current.md

Rules:
- The contract is binding
- Any violation of scope, intent, or forbidden patterns is BLOCKING
- All Blocking issues must reference a contract clause

Performance Gate:
- If trigger = YES, missing complexity or scale analysis is BLOCKING
- If trigger = NO, added optimization complexity must be justified or removed

Do not introduce new requirements.
Do not review beyond the provided diff and contract.
