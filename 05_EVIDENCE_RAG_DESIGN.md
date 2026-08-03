# 5. Evidence RAG Design

## 5.1 位置付け

Evidence RAGは補助機能ではなく、構築時間短縮と品質向上の中心機能である。

設計書は期待状態を示す。エビデンスは実際の状態を示す。システムは両者と過去の正常・異常・是正事例を比較し、次に確認すべき対象を提示する。

## 5.2 収集対象

### HMC
- `lssyscfg`
- `lshwres`
- LPAR Profile
- Virtual Ethernet / Virtual FC
- CPU、Memory、Boot Mode

### VIOS
- `ioslevel`
- `lsmap -all -npiv`
- `lsmap -all`
- `lsdev`
- `entstat`
- `fcstat`
- SEA、vFC、vfchost、Backing Device

### AIX
- `oslevel -s`
- `lspv`
- `lsvg`, `lsvg -p`, `lsvg -l`
- `lsdev -Cc disk`
- `lspath`, `lsmpio`
- `ifconfig -a`, `netstat -rn`
- `/etc/filesystems`
- `no`, `vmo`, `ioo`
- `errpt`
- `lslpp`, `instfix`

### PowerHA
- Cluster topology
- Network / Service Label
- Resource Group
- Verify / Sync結果
- Cluster / Node / RG状態
- `hacmp.out`等の関連ログ

### 試験
- Failover前後
- Failback前後
- VIOS停止
- FC path遮断
- Application stop/start
- Backup/restore検証

## 5.3 パイプライン

1. Collect
2. Integrity hash生成
3. Raw原本保存
4. Secret / Identifier Redaction
5. Parser適用
6. Fact / Relation生成
7. Chunk生成
8. Metadata付与
9. Structured Store登録
10. Keyword / Vector Index登録
11. Topology Graph更新
12. Quality Gate

## 5.4 チャンク戦略

### Command Chunk
1コマンドの入力、出力、終了コード、対象、時刻。

### Object Chunk
hdisk、VG、LPAR、vFC、RGなど、対象単位で複数Evidenceを統合。

### Phase Snapshot
pre-build、post-storage、post-cluster、post-failoverなどの時点断面。

### Incident Window
障害発生前後のログ、変更、状態、是正を時系列でまとめる。

### Topology Subgraph
`LPAR -> vFC -> VIOS -> FC -> Fabric -> LUN -> hdisk -> VG -> FS -> RG`の部分経路。

## 5.5 メタデータ

- platform
- product
- version
- layer
- environment
- project
- build_phase
- object_type
- object_id
- node
- cluster
- resource_group
- command
- status
- classification
- normality
- incident_id
- remediation_id
- collected_at
- approved
- confidentiality
- parser_version

## 5.6 検索方式

### Structured Filter
製品、バージョン、工程、対象、正常/異常、承認状態で絞る。

### Keyword Search
エラーコード、コマンド、hdisk、VG、RG、WWPN、メッセージ断片を検索する。

### Vector Search
自然言語の所見、類似障害、原因説明、是正内容を検索する。

### Graph Search
依存関係を辿り、異常点の上流・下流を特定する。

### Reranking
以下を重視する。

1. 同一製品・近いバージョン
2. 同一トポロジー
3. 同一工程
4. 承認済み正常例または確定障害
5. 根拠Evidenceの完全性
6. 新しさ。ただし古い安定知識を不当に排除しない

## 5.7 Golden Baseline

ゴールデンエビデンスは、正常に構築・試験され、人間承認されたEvidencePackageから作成する。

条件:

- 対象構成が明示されている
- 主要チェックが完了している
- Failover試験結果がある
- 未解決Findingがない、または許容判断がある
- Parser版と設計版が記録されている

## 5.8 回答生成

回答は以下の形式を必須とする。

- 結論
- 検出差分
- 影響
- 根拠Evidence ID
- 類似事例ID
- 確定事項と推定事項の分離
- 推奨する追加確認
- 実行してはならない操作
- 未確認事項

## 5.9 Hallucination抑制

- Evidence未取得項目を「正常」と断定しない
- 類似事例を今回の原因と断定しない
- 回答内の各主張をEvidenceまたはRuleへ紐付ける
- 根拠が不足する場合は追加収集コマンドを提示する
- 直接引用するRaw Evidenceを限定し、機密情報を除去する

## 5.10 学習への接続

- 正常結果: Golden候補
- 異常結果: Incident候補
- 人間訂正: Review Memory
- 是正成功: Remediation Knowledge
- 再発可能: Rule候補
- 過去問題: Regression Case
