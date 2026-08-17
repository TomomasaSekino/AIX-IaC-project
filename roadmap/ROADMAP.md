# Roadmap

## Phase 0: Design Baseline v0.2
- 研究目的と非対象を明確化
- PowerVM / HMC / VIOS / SAN / AIX / PowerHAの論理全体設計
- PowerVS live validation境界を定義
- Virtual Reference Platformを定義
- Evidence origin (`live / simulated / documented`)を導入
- Knowledge / Evidence / Case RAGの三層化
- NIM / Release / Promotion / Golden Releaseモデルを追加
- JSON Schema / Sample / ADR更新

## Phase 1: PowerVS Minimal IaC MVP
- IBM Cloud / PowerVS検証環境準備
- Terraform Provider / Module選定
- PowerVS Workspace
- Network
- AIX VSI 1台
- Volume
- `terraform apply -> Evidence -> destroy`
- Terraform desired stateとAIX実測値の比較

### 完成条件
TerraformでAIXを1台構築し、AIX自身のEvidenceで設計どおり作られたことを確認し、残存Resourceなく削除できる。

## Phase 2: Evidence RAG MVP
- AIX主要Command Collector
- `oslevel / prtconf / lsdev / lspv / lsvg / lspath / lsmpio / errpt` Parser
- EvidencePackage v0.2
- Raw / Structured Store
- Evidence origin管理
- Keyword + Vector検索
- Evidence引用付き回答
- Current vs Golden差分

## Phase 3: PowerHA Live Validation
- AIX 2 node
- host separation / placement条件
- Shareable Volume
- MPIO
- PVID確認
- Enhanced Concurrent VG
- LV / JFS2
- PowerHA導入
- Cluster / RG / Service IP
- Verify / Sync
- Failover / Failback
- live Evidence収集

### 完成条件
2ノードPowerHA環境をIaCで再現し、Shared StorageからRGまでのEvidenceを一貫追跡できる。

## Phase 4: Virtual Power Platform
- Dual HMC論理設計
- Dual VIOS論理設計
- SEA redundancy
- NPIV / vSCSI
- Dual FC Fabric
- SAN mapping
- HMC / VIOS / SAN simulated Evidence
- Topology Graph
- live / simulated境界表示

### 完成条件
PowerVSで直接触れないPower上位層についても、実務相当の設計とEvidence検証ロジックを示せる。

## Phase 5: Deterministic Validation
- Topology Rule
- MPIO path Rule
- PVID / VG / major number Rule
- Enhanced Concurrent VG Rule
- FS / mount policy Rule
- PowerHA Rule
- Evidence coverage Rule
- Golden Baseline比較
- Markdown / JSON Report

## Phase 6: NIM Lifecycle
- NIM Server構築
- NIM client登録
- resource model
- TL / SP / PTF適用
- pre/post update Evidence
- oslevel / fileset検証
- mksysb取得
- mksysb metadata管理

### 完成条件
NIMによるAIX更新をIaC/Workflowから呼び出し、更新前後Evidenceとmksysbを追跡できる。

## Phase 7: Release Promotion MVP
- Release Schema
- Application Deploy Adapter
- DEV environment
- QA environment
- Release identity / checksum
- Compatibility Test
- Promotion Gate
- LLM Pre-change Review
- LLM Post-change Evidence Analysis
- LLM Promotion Risk Summary

### 完成条件
同一ReleaseをDEVからQAへ昇格し、AIX level、Application artifact、Test、Evidenceが同一条件で再現されたことを証明できる。

## Phase 8: Golden Release
- PROD-equivalent最終検証
- Failover / Failback test
- Evidence Snapshot固定
- NIM mksysb取得
- Golden Release登録
- 次ReleaseのBaselineとして利用

### 完成条件
`Release + Test + Evidence + mksysb` を一つの検証済み復旧基準として扱える。

## Phase 9: Learning Loop
- Test Failure Case
- Incident / Remediation Case
- Rule Candidate生成
- Regression Case生成支援
- Golden Baseline / Golden Release更新候補
- Retrieval evaluation
- Human Approval後の昇格

## Phase 10: Expanded Platform
- HMC / VIOS実機環境への将来Adapter接続
- SAN / FC Switch Adapter拡張
- NIM復旧自動化研究
- Application Deploy製品連携拡張
- Graph Retrieval強化
- 運用Evidenceの長期評価

## 非対象ロードマップ
以下は別研究テーマとする。

- ITSM platform
- ServiceNow代替
- 自律Incident Commander
- 無承認自動復旧
- 完全自律SRE運用

## 研究上の主要評価
- 手作業に対する構築/更新時間短縮
- Evidence Coverage
- Configuration Defect検出率
- Promotion再現性
- Golden Releaseによる次回変更前分析時間短縮
- LLM追加確認の有効率
- 過去Case再利用率
