# ADR-0005: Bounded Authorization and Fail-Stop Execution

## Status

Accepted

## Context

This project introduces AI-assisted implementation, validation, release, and investigation workflows around enterprise AIX / Power infrastructure.

A key operational risk is not only an incorrect first action, but an agent continuing to mutate the environment after an approved hypothesis fails. For example, approval to install or reconfigure one tool must not become implicit authorization to continue changing PATH, services, packages, runtime configuration, infrastructure, AIX state, NIM state, or PowerHA state until the original objective is achieved.

Enterprise operations require explicit control over where automated reasoning stops.

## Decision

Adopt **bounded authorization** and **fail-stop execution** as project-wide execution governance.

1. Human approval is scoped to the explicitly proposed action, target, parameters, expected result, and stated retry policy.
2. Approval for one action does not authorize a different remediation, adjacent operation, or new hypothesis.
3. After each state-changing action, Observed Evidence is compared with the Expected Result.
4. If the result is unexpected, state-changing execution stops.
5. After fail-stop, only pre-authorized read-only diagnostics may continue.
6. Any new state-changing remediation requires a new Plan/hypothesis and new approval.
7. Retry is allowed only through an explicit bounded retry policy. Ad-hoc retry loops are prohibited.
8. A tool not visible in an agent execution session must not be assumed absent from the host. Environment mutation requires explicit authorization.
9. Approval scope, execution, result, retry, stop condition, and Evidence must be traceable.

Reference state model:

```text
APPROVED
  ↓
EXECUTING
  ↓
OBSERVING
  ├─ Expected   → CONTINUE
  └─ Unexpected → STOPPED_UNEXPECTED
                     ↓
              READ-ONLY DIAGNOSIS
                     ↓
                   REPORT
                     ↓
                   REPLAN
                     ↓
                REAPPROVAL
```

## Consequences

Positive:

- prevents approval scope from expanding silently
- limits blast radius of AI or automation mistakes
- makes unexpected conditions visible rather than automatically hidden by remediation
- preserves auditability and human control
- applies consistently from development toolchains to PowerVS, AIX, NIM, PowerHA, application deployment, and recovery
- allows safe diagnosis to continue through an explicit read-only diagnostic envelope

Trade-offs:

- some recovery or troubleshooting sequences require additional Human approval
- Plans need clearer expected results, retry policies, and stop conditions
- automation may stop more often in ambiguous situations

These trade-offs are accepted because predictable stop behavior is more important than autonomous completion in enterprise infrastructure operations.

## Rejected Alternatives

### Broad objective-based approval

Rejected because approval such as "make Terraform work" or "restore the cluster" would allow an agent to choose unbounded state-changing actions while pursuing the objective.

### Fully automatic remediation after unexpected results

Rejected because a failed hypothesis changes the known risk state and requires re-evaluation before additional mutations.

### Stop all activity after any failure

Rejected because pre-authorized read-only diagnostics are necessary to capture Evidence and formulate the next safe Plan.
