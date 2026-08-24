# 10. Test and Evaluation

## 10.1 テスト層

### Unit Test
- Parser
- Normalizer
- Rule
- Schema
- Graph relation
- Redaction
- Evidence origin handling
- Release state transition

### Contract Test
- Agent入出力Schema
- Adapter interface
- EvidencePackage
- Plan
- Release
- Promotion Decision
- Golden Release

### Integration Test
- Design -> Plan
- Plan -> PowerVS/AIX/NIM execution
- Sample Evidence -> Finding
- NIM update -> post-update Evidence
- Release -> Test -> Promotion
- Promotion -> mksysb -> Golden Release
- Finding -> Report
- Test failure -> Case / Rule Candidate

### Regression Test
過去障害、誤検出、Promotion failureを再現する。

### Simulation Test
実機で直接触れないHMC、VIOS、SAN等の上位Power層を模擬Evidenceで検証する。

### Local Validation / CI Test

Intel Mac mini上のLima/QEMU x86_64 LinuxをGitHub Actions self-hosted runnerとして利用し、Pull Request head commitを固定した非live Validationを実行できる。

対象例:

- `terraform fmt -check`
- `terraform init -backend=false`
- `terraform validate`
- Secret Scan
- Schema / Rule / Parser Test
- Regression / Simulation Test

Validation EvidenceはGit revision、tool version、command、exit code / result、execution environmentを追跡可能にする。

Local Validation / CI TestはTerraformコードや検証ロジックの再現性を証明するが、PowerVS / AIX / NIM / PowerHAのlive stateを証明するものではない。live stateをAcceptance CriteriaとするテストはPowerVS Field Validation等で別途実施する。

### PowerVS Field Validation
PowerVS上で以下を実機検証する。

- AIX VSI / LPAR作成・削除
- Network / Volume
- MPIO / PVID / VG / LV / JFS2
- Enhanced Concurrent VG
- NIM client / update / mksysb
- PowerHA
- Failover / Failback
- Evidence collection

### Promotion Test
DEV -> QA -> PROD-equivalentを同一Releaseで昇格できることを検証する。

## 10.2 評価指標

### 構築・更新効率
- Build Lead Time
- AIX update Lead Time
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
- Release promotion failure rate
- 再発率

### RAG
- Retrieval Precision@K
- Retrieval Recall@K
- MRR
- Citation Accuracy
- Version Compatibility Accuracy
- Release Compatibility Retrieval Accuracy
- Golden Baseline Match Quality
- Evidence Origin Accuracy

### LLM
- 根拠付き回答率
- 根拠なし断定率
- simulated evidence誤断定率
- 追加確認の有効率
- Test failure hypothesis採用率
- Promotion Risk Summary有用率
- 誤った高リスク提案率

### Promotion
- Same Release Identity率
- DEV -> QA再現率
- QA -> PROD-equivalent再現率
- Required Test completion rate
- Promotion Gate false pass rate
- Promotion Gate false stop rate
- Golden Release作成成功率

### 学習
- Rule Candidate採用率
- Regression追加数
- Golden Release増加数
- Incident / Test failure再発防止率
- Retrieval改善率
- 誤検出修正までの時間

## 10.3 初期目標値

以下は研究初期の暫定値で、PowerVS実測後に更新する。

- Evidence Coverage: 90%以上
- 主要Rule検出率: 95%以上
- Citation Accuracy: 100%
- Evidence Origin Accuracy: 100%
- 根拠なし高リスク断定: 0件
- simulatedをliveと誤認する回答: 0件
- 過去障害Regression再検出率: 100%
- Promotion Gate false pass: 0件
- 公開Sampleの機密情報検出: 0件

## 10.4 初期評価データセット

### Virtual Reference Platform
- 正常Dual HMC / Dual VIOS / Dual Fabric構成
- NPIV経路不足
- 同一VIOSへの経路偏り
- SEA冗長性設計不備

### PowerVS Live
- AIX単一ノード正常構築
- Volume追加
- SAN path不足相当のMPIO異常
- PVID不一致
- Enhanced Concurrent VG属性不備
- major number不一致
- `/etc/filesystems`不適切設定
- PowerHA verify/sync失敗
- RG policy不一致
- Failover後Application起動失敗

### NIM / Release
- PTF適用成功
- target oslevel不一致
- fileset更新不整合
- PTF適用後Test failure
- Application artifact違い
- DEV PASS / QA FAIL
- Evidence不足によるPromotion Stop
- Approved Exception付きPromotion
- mksysb取得成功 / 失敗

## 10.5 研究MVP

### MVP-1
TerraformでPowerVS上にAIXを1台作成し、設計値と実測Evidenceを比較し、完全削除する。

### MVP-2
AIX 2台 + Shared Volume + MPIO + Enhanced Concurrent VG + JFS2 + PowerHAを検証する。

### MVP-3
NIMからAIX更新を流し、Application Deploy、Test、Evidence Gateを実行する。

### MVP-4
同一ReleaseをDEV -> QAへ昇格し、成功後mksysbをGolden Releaseへ紐付ける。

## 10.6 Release Gate

ソフトウェアReleaseには以下を要求する。

- 全Schema test成功
- Rule regression成功
- Parser golden test成功
- Evidence citation test成功
- Evidence origin test成功
- Promotion state machine test成功
- Secret scan成功
- Architecture / ADR更新
- 既知制約をRelease Noteへ記載

## 10.7 Research Evaluation

単なるデプロイ成功ではなく、以下を研究成果として測定する。

- 手作業と比較して構築・更新時間がどれだけ減ったか
- Evidenceにより確認漏れがどれだけ減ったか
- Golden Releaseにより次回変更前評価がどれだけ速くなったか
- LLMが追加した確認項目のうち実際に有効だった割合
- 過去Caseが次回障害・Test failure解析へどれだけ再利用されたか
