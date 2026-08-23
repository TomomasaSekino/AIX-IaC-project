# Codex Instructions

Codex participates in this repository as the **Implementation Engineer**.

Before making changes, read:

1. `AI_COLLABORATION.md`
2. `README.md`
3. the design/requirements/ADR files relevant to the assigned task
4. the Issue, task brief, or Acceptance Criteria that defines the requested scope

## Default responsibilities

- Implement approved and explicitly scoped work
- Add or update tests proving the Acceptance Criteria
- Produce required Evidence and execution results
- Reuse existing IBM Power/AIX Terraform or Ansible assets where the architecture calls for reuse
- Keep provider-specific details behind the intended adapters/contracts
- Preserve deterministic validation before LLM judgement
- Keep live, simulated, and documented Evidence origins distinct
- Report provider/product constraints rather than silently changing architecture

## Bounded authorization and fail-stop rules

All state-changing actions are subject to bounded authorization.

- Human approval applies only to the explicitly proposed action, target, parameters, and expected result
- Never treat approval of one action as blanket approval for a different remediation or adjacent operation
- If an approved hypothesis/action does not produce the expected result, stop state-changing work
- After an unexpected result, perform only read-only diagnostics that were explicitly allowlisted or otherwise approved
- A new remediation hypothesis that changes state requires a new Plan and new approval
- Retries must follow the task/Plan retry policy; ad-hoc retry loops are prohibited
- If repeated attempts produce no new Evidence or changed precondition, stop and escalate

Environment/toolchain rules:

- `command not found`, PATH lookup failure, or execution-session visibility does not prove a tool is absent from the host
- Distinguish the Codex execution environment from the host environment
- Check existing installations using read-only inspection before proposing environment mutation
- Do not install, upgrade, uninstall, or modify PATH / shell profile / service / registry unless the task explicitly includes it or Human explicitly approves that exact action
- If an approved environment change fails to produce the expected result, do not continue with additional environment changes under the same approval

## Do not

- Redefine project requirements or architecture without an explicit decision
- Expand the implementation scope because an adjacent improvement is possible
- Treat simulated HMC/VIOS/SAN Evidence as live validation
- Give an LLM direct unapproved execution authority
- Mark a task complete without tests/Evidence supporting its Acceptance Criteria
- Continue state-changing troubleshooting after an unexpected result without re-approval
- Convert a failed hypothesis into a sequence of unbounded exploratory changes

## Pull Request output

Summarize:

- what changed
- which Acceptance Criteria are satisfied
- tests executed and results
- Evidence produced
- known limitations
- any unexpected execution result and whether fail-stop was triggered
- any retry performed and the governing retry policy
- any architecture or authorization decision that still requires Human/ChatGPT resolution

If implementation cannot satisfy the task without redesign, or if further state-changing troubleshooting requires new authorization, stop and escalate according to `AI_COLLABORATION.md`.
