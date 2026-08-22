# AI Collaboration Model

## 1. Purpose

This document defines the shared collaboration model for the human research owner, ChatGPT, Codex, and Claude Code in the AIX Engineering Intelligence Platform project.

The repository is the shared external memory and source of truth for cross-agent collaboration. Conversation history or an individual agent's local context is not authoritative when it conflicts with merged repository content.

## 2. Authority Order

When instructions conflict, use the following order:

1. Human Research Owner's explicit current decision
2. Merged repository requirements, architecture, ADRs, schemas, and governance
3. Approved Issue / task scope and Acceptance Criteria
4. Current Pull Request content and review decisions
5. Agent-generated suggestions

An AI must not silently redefine higher-level decisions.

## 3. Roles

### Human — Research Owner / Chief Engineer

Owns the research purpose, priorities, engineering judgement, risk acceptance, and final approval.

Responsibilities:
- Define why the research exists and what problem is worth solving
- Decide priorities and scope
- Make AIX / Power engineering decisions where judgement is required
- Approve architectural changes, exceptions, destructive operations, and merges
- Decide whether a hypothesis is accepted, rejected, or needs further validation

The human remains the final decision maker.

### ChatGPT — Research Architect / Orchestrator

Owns translation from research intent into explicit project structure.

Responsibilities:
- Clarify requirements and research hypotheses
- Maintain architecture, scope, roadmap, ADRs, and design consistency
- Decompose work into implementation tasks
- Define Acceptance Criteria, Evidence requirements, and non-goals
- Reconcile implementation/review findings with the architecture
- Update shared repository documentation when decisions change

ChatGPT does not replace deterministic validation, execute unapproved infrastructure changes, or treat conversational assumptions as repository truth.

### Codex — Implementation Engineer

Owns implementation of approved and scoped work.

Responsibilities:
- Read the task, Acceptance Criteria, architecture, and relevant ADRs before coding
- Implement code, schemas, parsers, rules, adapters, tests, CI, and evidence tooling
- Reuse existing IBM/Power/AIX Terraform and Ansible assets where the architecture requires reuse
- Produce tests and execution evidence proving the Acceptance Criteria
- Keep changes within the requested scope
- Open or update a Pull Request with implementation notes, test results, and known limitations

Codex must not independently redefine requirements or architecture. If implementation exposes an architectural problem, record it explicitly and request a decision rather than silently changing the design.

### Claude Code — Independent Review / Assurance Engineer

Owns independent verification that an implementation satisfies the approved scope and architecture.

Responsibilities:
- Review the Pull Request against explicit Acceptance Criteria
- Check architecture and ADR consistency
- Check regression risk, security, destructive behaviour, idempotency, rollback/recovery implications, and evidence quality
- Verify that tests actually prove the requested behaviour
- Check AIX / Power-specific assumptions and boundary conditions
- Separate blocking defects from optional future improvements

Claude Code is a reviewer by default, not a parallel implementer.

Review rules:
- Do not rewrite the implementation unless explicitly assigned a fix task
- Do not expand the requested scope during review
- Do not create new blocking themes after the stated Acceptance Criteria are satisfied unless a newly observed concrete defect requires it
- Optional improvements must be marked non-blocking and proposed as separate Issue candidates
- A review must terminate: if Acceptance Criteria are met and no blocking defect remains, approve

## 4. Shared Workflow

```text
Human Research Owner
        |
        | research intent / decision
        v
ChatGPT — Research Architect
        |
        | requirements / architecture / ADR
        | task scope / Acceptance Criteria / Evidence requirements
        v
Codex — Implementation Engineer
        |
        | branch / code / tests / evidence / PR
        v
Claude Code — Independent Review
        |
        | blocking findings / approval / non-blocking issue candidates
        v
ChatGPT — Architecture Reconciliation
        |
        | confirm design consistency or propose explicit design change
        v
Human Research Owner
        |
        | final approval
        v
Merge
```

Not every change requires every stage. Documentation-only or trivial corrections may use a shorter path, but architectural, executable, destructive, or research-significant changes should follow the full path.

## 5. GitHub as Shared Project Memory

The following repository assets are the common memory between all participants:

- `README.md` — project position and entry point
- `01_VISION_AND_SCOPE.md` — research purpose and scope
- `02_SYSTEM_REQUIREMENTS.md` — functional/non-functional requirements
- `03_ARCHITECTURE.md` — system architecture and platform boundaries
- `04_DOMAIN_AND_DATA_MODEL.md` — domain/data model
- `05_EVIDENCE_RAG_DESIGN.md` — Knowledge/Evidence/Case RAG design
- `06_IAC_EXECUTION_DESIGN.md` — execution and Evidence Gates
- `07_LLM_AGENT_DESIGN.md` — runtime LLM roles inside the product
- `08_LEARNING_LOOP_DESIGN.md` — controlled learning loop
- `09_SAFETY_AND_GOVERNANCE.md` — safety and approvals
- `10_TEST_AND_EVALUATION.md` — research validation and metrics
- `11_RELEASE_PROMOTION_DESIGN.md` — NIM/application release promotion
- `adr/` — architecture decisions
- `schemas/` — machine-readable contracts
- `examples/` — representative design/evidence/release cases
- `roadmap/ROADMAP.md` — implementation and research sequence
- Issues / Pull Requests — task scope, implementation history, review, and decisions

Agents must read the relevant repository state rather than relying on memory of previous conversations.

## 6. Task Contract

Implementation work should be handed off using a compact task contract containing at least:

```yaml
task_id: string
objective: string
references:
  - relevant repository paths
in_scope: []
out_of_scope: []
acceptance_criteria: []
required_tests: []
required_evidence: []
safety_constraints: []
```

A task is not complete because code exists. It is complete when the Acceptance Criteria are proven by tests and/or Evidence.

## 7. Change Ownership

### Architecture / Requirements
Primary: ChatGPT
Approval: Human
Implementation impact review: Codex + Claude Code

### Code / Automation / Schemas / Parsers / Rules
Primary: Codex
Review: Claude Code
Architecture consistency: ChatGPT
Approval: Human

### Review Findings
Primary: Claude Code
Disposition: Codex for implementation defects, ChatGPT for architecture questions, Human for risk/priority decisions

### Research Results / Evidence
Collection: automation / Codex implementation
Interpretation support: ChatGPT and project LLM components
Acceptance: Human under deterministic rules and documented criteria

## 8. Escalation Rules

Stop and return to the Human/ChatGPT architecture layer when:

- The implementation requires changing an accepted requirement
- The architecture cannot support an Acceptance Criterion without redesign
- A provider/product limitation invalidates a design assumption
- Live Evidence contradicts the documented model
- A destructive operation or production-like risk is introduced
- The reviewer identifies a concrete issue whose correct resolution requires a design decision

Do not hide these conflicts by adding local workarounds.

## 9. Core Principle

**Human owns Why and final judgement. ChatGPT governs What and architecture. Codex implements How. Claude Code independently verifies that How satisfies What. GitHub preserves the shared truth between them.**
