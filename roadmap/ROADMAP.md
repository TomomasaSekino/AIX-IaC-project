# Roadmap

## Phase 0: Design Baseline
- 本設計文書
- JSON Schema
- 正常・異常サンプル
- ADR
- GitHubリポジトリ初期化

## Phase 1: Evidence RAG MVP
- AIX主要コマンドCollector
- lspv / lsvg / lspath / lsdev Parser
- EvidencePackage
- Raw / Structured Store
- Keyword + Vector検索
- Evidence引用付き回答

## Phase 2: Deterministic Validation
- Design Schema
- Topology Graph
- MPIO path、PVID、VG属性、FS、RGのRule
- Golden Baseline比較
- Markdown Report

## Phase 3: IaC Plan Generation
- HMC Plan Generator
- VIOS NPIV Mapping Plan
- AIX LVM/JFS2 Plan
- PowerHA Plan
- Dry-runとPlan Diff

## Phase 4: Controlled Execution
- Approval Gate
- 閉域Executor
- 工程別Evidence Gate
- 再実行とDrift検出

## Phase 5: Incident Learning
- Incident / Remediationモデル
- Rule Candidate生成
- Regression Case自動生成支援
- 人間承認後の昇格

## Phase 6: Expanded Platform
- SAN / FC Switch Adapter
- VIOS / HMC Parser拡張
- Graph Retrieval
- Failover試験自動化
- 運用監視・バックアップとの連携

## MVP完成条件
- 2ノードPowerHAサンプルを設計から検証まで追跡できる
- 主要な異常サンプルをRuleとEvidence RAGで説明できる
- 過去障害を回帰試験に昇格できる
- すべての高リスク指摘が根拠Evidenceを持つ
