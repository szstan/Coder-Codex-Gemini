# Implementation Contract (Example)

## Summary
- Goal: Add health check endpoint
- Non-goals: No refactor of existing APIs
- Constraints: Backward compatible

## Scope
- backend/api/health.py
- backend/app.py

## Intent
- Provide system health status

## Must-Not-Change Behaviors
- Existing endpoints unchanged

## Performance
- Performance trigger: NO
- Default to simplicity

## Forbidden Patterns
- No caching
- No background threads

## Testing
- Unit tests for healthy and unhealthy paths
