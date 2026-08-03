# 6. IaC Execution Design

## 6.1 基本原則

- 設計、Plan、実行、Evidenceを分離する
- LLMはPlanを提案できるが実行しない
- 承認済みPlanだけを実行する
- 各工程の前後でEvidenceを取得する
- 途中失敗から安全に再開できる
- 実行順序と依存関係を明示する

## 6.2 実行フェーズ

1. `validate`
2. `preflight`
3. `plan`
4. `review`
5. `approve`
6. `apply_hmc`
7. `apply_vios`
8. `apply_aix_base`
9. `apply_storage`
10. `apply_powerha`
11. `verify`
12. `failover_test`
13. `close`
14. `learn`

## 6.3 Planの内容

- plan_id
- design_version
- target_environment
- ordered_steps
- required_credentials
- preconditions
- commandsまたはmodule calls
- expected_changes
- expected_evidence
- timeout
- retry_policy
- rollback_action
- stop_condition
- risk_level
- approval_status

## 6.4 実行Adapter

- HMC Adapter
- VIOS Adapter
- AIX Adapter
- PowerHA Adapter
- SAN Adapter
- FC Switch Adapter

各Adapterは、製品・バージョン差を隠蔽し、標準操作インターフェースを提供する。

## 6.5 Idempotency

各Stepは以下の順序で処理する。

1. Current State取得
2. Desired Stateとの比較
3. 変更不要ならskip
4. 変更必要ならapply
5. Post Evidence取得
6. Expected State検証

## 6.6 再実行

- Step単位で状態を保持
- 失敗Stepから再開可能
- 既完了StepはEvidenceで再確認
- 設計またはPlanが変わった場合は再承認
- 途中で手動変更があればDriftとして検出

## 6.7 ロールバック

PowerVM/AIX基盤では完全自動ロールバックが危険な場合があるため、以下を区別する。

- Automatic rollback: 安全性が証明された変更
- Compensating action: 元に戻す代替操作
- Manual recovery: 人間手順が必要
- No rollback: 事前バックアップ・復旧方針で担保

## 6.8 Evidence Gate

次工程へ進む前に、最低限のEvidence条件を満たす。

例:

- vFC mappingが両VIOSに存在
- 必要パス数が有効
- PVIDがノード間で一致
- VG属性がPowerHA前提に一致
- JFS2が期待属性で作成
- Cluster verifyが成功
- RGが期待ノードでOnline

## 6.9 GitHub連携

- Design変更はPull Request
- CIでSchema、Rule、生成Plan、回帰試験
- Plan差分をレビュー
- 承認タグまたは署名をExecution Gateへ渡す
- 実行結果とEvidence ReportをPRまたはReleaseへ紐付ける
