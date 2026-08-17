# 5. Evidence RAG Design

## 5.1 位置付け

Evidence RAGは補助機能ではなく、構築時間短縮、変更影響分析、Release昇格判断支援、障害調査支援、学習の中核である。

設計書は期待状態を示し、Evidenceは実際または想定された状態を示す。本システムは設計・実測・模擬・過去事例を混同せず、出自を保ったまま比較する。

## 5.2 RAGの三層構造

### Knowledge RAG
Power/AIX基盤の設計・運用知識を保持する。

- PowerVM設計原則
- HMC / VIOS
- NPIV / vSCSI / SEA
- SAN / MPIO
- AIX / LVM / JFS2
- NIM
- PowerHA
- Release / Promotion運用

### Evidence RAG
構成・状態・変更・試験のEvidenceを保持する。

- HMC simulated evidence
- VIOS simulated evidence
- SAN simulated evidence
- PowerVS live evidence
- AIX live evidence
- NIM execution evidence
- PowerHA live evidence
- Test evidence
- mksysb metadata

### Case RAG
経験を事例として保持する。

- 正常構築
- Release成功例
- Test failure
- 障害
- 根本原因
- 是正
- 設計判断
- Regression Case
- Golden Release

## 5.3 Evidence出自

PowerVSではHMC / VIOS / SAN Fabricを利用者が直接検証できないため、Evidenceの出自を必須属性とする。

```yaml
evidence_origin: live | simulated | documented
validation_status: verified | assumed | unverified
layer: hmc | powervm | vios | san | aix | nim | powerha | application
platform: powervs | virtual_reference | other
```

ルール:

- `live` と `simulated` を同じ確度として扱わない
- LLMはsimulated evidenceを実測事実として断定しない
- Reportでは出自を表示する
- Golden Releaseの必須基準は原則live evidenceとする

## 5.4 収集対象

### HMC / PowerVM - simulated or future live
- `lssyscfg`
- `lshwres`
- LPAR Profile
- Virtual Ethernet / Virtual FC
- CPU / Memory / Boot Mode

### VIOS - simulated or future live
- `ioslevel`
- `lsmap -all -npiv`
- `lsmap -all`
- `lsdev`
- `entstat`
- `fcstat`
- SEA / vFC / vfchost / Backing Device

### SAN - simulated or future live
- WWPN
- Fabric A/B
- Zone
- LUN mapping
- Host mapping
- path topology

### PowerVS / AIX - live
- PowerVS instance / volume / network metadata
- `oslevel -s`
- `prtconf`
- `lsdev`
- `lspv`
- `lsvg`, `lsvg -p`, `lsvg -l`
- `lspath`, `lsmpio`
- `fcstat`
- `entstat`
- `ifconfig -a`, `netstat -rn`
- `/etc/filesystems`
- `no`, `vmo`, `ioo`
- `errpt`
- `lslpp`, `instfix`

### NIM - live
- NIM object definitions
- client / resource mapping
- TL / SP / PTF適用結果
- command exit status
- pre/post oslevel
- mksysb creation metadata
- mksysb inventory

### PowerHA - live
- Cluster topology
- Network / Service Label
- Resource Group
- Shared VG / FS mapping
- Verify / Sync
- Cluster / Node / RG status
- Failover / Failback結果
- `hacmp.out`等の関連ログ

### Release / Test
- Release definition
- Application artifact version
- Deployment result
- Test suite / test result
- Promotion decision
- Approved exception
- Golden Release metadata

## 5.5 Pipeline

1. Collect
2. Integrity hash生成
3. Raw原本保存
4. Secret / Identifier Redaction
5. Origin / Validation Status付与
6. Parser適用
7. Fact / Relation生成
8. Chunk生成
9. Metadata付与
10. Structured Store登録
11. Keyword / Vector Index登録
12. Topology Graph更新
13. Release / Case関連付け
14. Quality Gate

## 5.6 Chunk戦略

### Command Chunk
1コマンドの入力、出力、終了コード、対象、時刻。

### Object Chunk
hdisk、VG、LPAR、vFC、RG、NIM client等の対象単位。

### Phase Snapshot
pre-build、post-PTF、post-storage、post-cluster、post-deploy、post-test、post-failover等の断面。

### Release Snapshot
AIX level、PTF、Application artifact、Test Result、EvidenceをRelease単位で固定する。

### Incident / Failure Window
異常発生前後の変更、ログ、状態、是正を時系列でまとめる。

### Topology Subgraph
`LPAR -> vFC -> VIOS -> FC -> Fabric -> LUN -> hdisk -> VG -> FS -> RG -> Application` の部分経路。

## 5.7 検索方式

### Structured Filter
製品、バージョン、環境、Release、工程、Object、Origin、Validation Status、正常/異常、承認状態で絞る。

### Keyword Search
AIX error ID、コマンド、hdisk、VG、RG、WWPN、fileset、PTF、メッセージ断片を検索する。

### Vector Search
自然言語の所見、類似障害、適合性問題、是正内容、設計判断を検索する。

### Graph Search
依存関係を辿り、異常点の上流・下流を特定する。

### Reranking
優先条件:

1. 同一製品・近いバージョン
2. 同一Release条件またはAIX level
3. 同一トポロジー
4. 同一工程
5. live / verified Evidence
6. 承認済み正常例または確定障害
7. Evidence完全性
8. 新しさ

## 5.8 構築・更新時のRAG利用

RAGは障害時だけでなく、変更前から利用する。

```text
Design / Release Definition
        ↓
Similar Golden / Case Retrieval
        ↓
Pre-change LLM Review
        ↓
IaC / NIM / Deploy
        ↓
Evidence Collection
        ↓
Golden Comparison
        ↓
Past Failure Retrieval
        ↓
Test / Promotion Gate
```

## 5.9 Golden Baseline / Golden Release

### Golden Baseline
正常に構築・試験・承認された構成Evidence。

### Golden Release
Promotionを完了したReleaseに以下を結合したもの。

- AIX oslevel
- PTF / TL / SP
- Middleware version
- Application version
- IaC version
- Test result
- Evidence snapshot
- Approved exceptions
- mksysb reference

Golden Releaseは次回更新前の比較基準かつ復旧基準となる。

## 5.10 LLM回答ルール

回答には以下を含める。

- 結論
- 確定差分
- 影響
- Evidence origin
- Evidence ID
- Rule ID
- Case ID
- Release ID
- 確定事項と推定事項の分離
- 推奨する追加確認
- 未確認事項

## 5.11 Hallucination抑制

- Evidence未取得項目を正常と断定しない
- simulated evidenceをlive evidenceとして扱わない
- 類似事例を今回の原因と断定しない
- Ruleで確定可能な項目をLLM判断へ委ねない
- 根拠不足時は追加収集Evidenceを提案する
- Raw Evidenceの機密情報をContextへ無制限に投入しない

## 5.12 Learning接続

- 正常構築: Golden Baseline候補
- Promotion成功: Golden Release候補
- Test失敗: Case候補
- 障害: Incident Case候補
- 人間訂正: Review Memory
- 是正成功: Remediation Knowledge
- 再発可能: Rule候補
- 過去問題: Regression Case
- mksysb: Golden Release recovery reference
