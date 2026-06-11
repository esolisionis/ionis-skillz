---
name: ai-risk-audit
description: Audit AI systems, LLM applications, agents, MCP integrations, and AI vendor products for security, governance, and compliance risk — OWASP LLM Top 10 (prompt injection, data exfiltration, insecure tool use), NIST AI Risk Management Framework, ISO 42001 AI governance, OWASP AI testing methodology, GDPR data protection, and task-appropriateness assessment. Use whenever the user is evaluating an AI vendor or tool, reviewing MCP server security, assessing prompt-injection or data-leakage risk, answering colleague questions about AI security policy, drafting AI governance documentation or rollout guardrails, deciding whether a use case is appropriate for AI, or preparing AI risk material for IT/legal/quality review. Also use for questions about egress allowlisting, agent permissions, or whether an AI workflow handles sensitive data safely.
---

# AI Risk Audit

Run structured risk assessments of AI systems using established frameworks rather than vibes. The audience is typically an AI program owner who must answer to IT security, legal, quality (GxP), and leadership — outputs should be defensible, framework-cited, and prioritized.

## Choose the framework

| Framework | When | Reference |
|---|---|---|
| **OWASP LLM Top 10** | Security review of an LLM app, agent, MCP server, or integration: prompt injection, insecure output handling, data exfiltration, excessive agency, supply chain. The default for "is this AI tool/integration safe?" | `references/owasp-llm-top10.md` |
| **OWASP AI testing** | Designing concrete tests/red-team exercises to validate an AI system before rollout. | `references/owasp-ai-testing.md` |
| **NIST AI RMF** | Organizational risk management: govern/map/measure/manage. For program-level governance, policy drafting, and risk registers. | `references/nist-ai-rmf.md` |
| **ISO 42001** | AI management system audit — for formal governance maturity assessment or certification-track questions. | `references/iso-42001-ai-governance.md` |
| **GDPR / data protection** | Personal data flowing through AI systems: lawful basis, minimization, transfers, DPIAs. Pair with local requirements (HIPAA etc. are out of scope of the reference — flag them separately). | `references/gdpr-audit.md` |
| **Task appropriateness** | "Should we use AI for this at all, and with how much autonomy?" — graduated assessment of AI suitability per task. Good for hackathon scoping and use-case intake triage. | `references/ai-assessment-scale.md` |

Load only what the question needs. For a vendor evaluation, OWASP LLM Top 10 + GDPR is the usual pair; for an MCP server review, OWASP LLM Top 10 alone usually suffices.

## MCP and agent integrations — the recurring questions

These come up constantly in enterprise Claude administration; anchor answers in the frameworks above:

- **Prompt injection via tool results** (OWASP LLM01): any MCP server returning third-party content (web pages, documents, tickets) can carry instructions. Mitigations: treat tool output as data, human confirmation for side-effectful actions, least-privilege scopes.
- **Data exfiltration paths** (LLM02/LLM06): egress allowlisting is the control — audit which domains a connector or sandbox can reach and what data could flow there. An allowlist is only as good as the most permissive domain on it.
- **Excessive agency** (LLM08): map which tools can write/send/delete, and whether each requires confirmation. Read-only connectors are a different risk class from write-capable ones.
- **Supply chain** (LLM05): remote MCP servers are third-party code you don't control; review authentication, hosting, data retention, and what the server logs.

## Report structure

```
# AI Risk Assessment — [system/vendor/integration]
**Framework(s):** [...] · **Scope:** [...] · **Date:** [...]

## Summary
[Risk posture in 2–4 sentences; the single most important mitigation.]

## Findings
[Grouped by risk level: Critical / High / Medium / Low. Each finding:
framework citation, the specific exposure, evidence, recommended mitigation,
and residual risk after mitigation.]

## Controls already in place
[What's working — calibrates the assessment.]

## Recommended actions
[Prioritized, each with owner-shaped phrasing ("IT: add X to the egress
review checklist") so the report is actionable in an enterprise setting.]
```

## Conduct rules

- Cite the framework item for every finding (e.g., "LLM01: Prompt Injection", "NIST AI RMF MAP-1.1") — that's what makes the output usable with security and compliance teams.
- Distinguish *demonstrated* risk from *theoretical* risk; say which is which.
- Don't certify. These audits inform decisions; formal compliance determinations belong to legal/quality. Say so in regulated contexts (GxP, patient data).
- If the user's question implies regulated data (PHI, clinical, patient-identifiable), flag that HIPAA/GxP analysis is needed beyond these frameworks.
