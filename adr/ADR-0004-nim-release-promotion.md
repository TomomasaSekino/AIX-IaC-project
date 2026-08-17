# ADR-0004: NIMとApplication DeploymentをRelease Promotionで統合する

## Status
Accepted

## Context

AIXではNIMがOSライフサイクル、PTF/TL/SP適用、mksysb等を担える一方、SAP TMSのようなDEV -> QA -> PRODの標準Promotion機構は持たない。

また、OS更新とApplication更新を別々に成功判定すると、PTF適用自体は成功していてもApplication互換性が崩れた状態を昇格させる危険がある。

## Decision

AIX更新とApplication artifactを一つのReleaseとして定義し、NIM、Application Deploy、Test、Evidence、Promotion Gateを同一Workflowへ統合する。

Releaseには以下を含める。

- AIX target oslevel
- TL / SP / PTF bundle
- Middleware version
- Application artifact / checksum
- IaC commit
- Test suite
- Evidence baseline
- Promotion policy

DEV、QA、PROD-equivalentで同一Releaseを再現し、Rule/Test/Evidence Gate合格後に昇格する。

最終昇格後はNIMからmksysbを取得し、Release + Test + Evidence Snapshot + mksysbをGolden Releaseとして保存する。

## Consequences

- NIMを単なるインストールサーバーではなくAIX Lifecycle / Recovery Engineとして利用できる
- PTF適合検証をApplication Releaseの一部として扱える
- DEV成功をQAで再現性として検証できる
- mksysbを検証済みReleaseの復旧ポイントとして利用できる
- Promotion Gate、Release Schema、Golden Releaseモデルが必要になる
- LLMはPromotion決定者ではなく変更影響・Evidence解釈・Risk Summaryを担当する
