# 10. Test and Evaluation

## 10.1 テスト層

### Unit Test
- Parser
- Normalizer
- Rule
- Schema
- Graph relation
- Redaction

### Contract Test
- Agent入出力Schema
- Adapter interface
- EvidencePackage
- Plan

### Integration Test
- DesignからPlan
- Sample EvidenceからFinding
- FindingからReport
- IncidentからRule Candidate

### Regression Test
過去障害と誤検出を再現する。

### Simulation Test
実機なしでHMC、VIOS、AIX、PowerHAの出力を模擬する。

### Field Validation
実機または検証環境で構築・Failoverを検証する。

## 10.2 評価指標

### 構築効率
- Build Lead Time
- 調査時間
- 再実行回数
- 手動確認時間
- First Pass Success Rate

### 品質
- Evidence Coverage
- Rule Detection Rate
- Defect Escape Rate
- False Positive Rate
- 未解決Finding数
- 再発率

### RAG
- Retrieval Precision@K
- Retrieval Recall@K
- MRR
- Citation Accuracy
- Version Compatibility Accuracy
- Golden Baseline Match Quality

### LLM
- 根拠付き回答率
- 根拠なし断定率
- 追加確認の有効率
- 人間採用率
- 誤った高リスク提案率

### 学習
- Rule Candidate採用率
- Regression追加数
- Incident再発防止率
- Golden Baseline増加数
- 誤検出修正までの時間

## 10.3 初期目標値

以下はMVP評価用の暫定値であり、実測後に更新する。

- Evidence Coverage: 90%以上
- 主要Rule検出率: 95%以上
- Citation Accuracy: 100%
- 根拠なし高リスク断定: 0件
- 過去障害Regression再検出率: 100%
- 公開サンプルの機密情報検出: 0件

## 10.4 評価データセット

- 正常なDual VIOS + NPIV構成
- SAN path不足
- 同一VIOSへの経路偏り
- PVID不一致
- Enhanced Concurrent VG属性不備
- major number不一致
- `/etc/filesystems`の不適切な自動mount
- PowerHA verify/sync失敗
- RG policy不一致
- Failover後のApplication起動失敗

## 10.5 Release Gate

Releaseには以下を要求する。

- 全Schema test成功
- Rule regression成功
- Parser golden test成功
- Evidence citation test成功
- Secret scan成功
- Architecture / ADR更新
- 既知の制約をRelease Noteへ記載
