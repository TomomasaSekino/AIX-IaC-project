# 6. IaC Execution Design

## 6.1 基本原則

- 設計、Plan、実行、Evidence、Promotionを分離する
- 既存Terraform / Ansible / NIM / PowerHA資産を実行部品として再利用する
- LLMはPlanや影響をレビューできるが直接実行しない
- 承認済みPlanだけをExecutorが実行する
- 各工程の前後でEvidenceを取得する
- 途中失敗から安全に再開できる
- Release単位でAIX更新とApplication更新を追跡する
- 承認は明示された操作境界に限定し、Unexpected ResultではFail-Stopする

## 6.2 実行レイヤー

### PowerVS Provisioning
- Workspace
- Network
- AIX VSI / LPAR
- Volume / Shareable Volume
- Placement / host separation条件

### AIX Configuration
- device discovery
- MPIO
- PVID
- VG / LV / JFS2
- Enhanced Concurrent VG
- tunables
- base package

### NIM Lifecycle
- client registration
- resource management
- TL / SP / PTF delivery
- pre/post oslevel evidence
- mksysb creation

### PowerHA
- cluster
- node
- network / service IP
- shared VG / FS
- resource group
- application controller
- verify / sync
- failover / failback

### Application Deployment
外部Deploy EngineまたはAnsible等をAdapter経由で利用する。

## 6.3 実行フェーズ

1. `validate`
2. `preflight`
3. `plan`
4. `retrieve_precedent`
5. `llm_pre_change_review`
6. `approve`
7. `apply_powervs`
8. `apply_aix_base`
9. `apply_storage`
10. `apply_powerha`
11. `nim_update`
12. `application_deploy`
13. `verify`
14. `compatibility_test`
15. `failover_test`
16. `promotion_review`
17. `promote`
18. `mksysb`
19. `golden_release`
20. `learn`

すべてのReleaseで全工程を実行する必要はない。変更種類に応じて適用フェーズを選択する。

## 6.4 Plan

Planには以下を持たせる。

- plan_id
- release_id
- design_version
- target_environment
- ordered_steps
- execution_adapter
- required_credentials
- preconditions
- commands / module calls
- expected_changes
- expected_result
- expected_evidence
- test_requirements
- promotion_requirements
- authorization_scope
- diagnostic_allowlist
- timeout
- retry_policy
- rollback_action
- stop_condition
- risk_level
- approval_status
- approval_identity / timestamp

ApprovalはPlan全体への曖昧な包括許可ではなく、Plan内で明示されたstate-changing stepとその条件に対して適用する。

## 6.5 Adapter

- PowerVS Terraform Adapter
- HMC Adapter
- VIOS Adapter
- AIX Adapter
- NIM Adapter
- PowerHA Adapter
- SAN / FC Adapter
- Application Deploy Adapter
- Test Adapter

PowerVSでHMC / VIOSを直接実行できない場合、当該AdapterはPlan生成・Simulation・Evidence検証モードで使用する。

## 6.6 Idempotency

各Stepは以下の順序で処理する。

1. Current State取得
2. Desired Stateとの比較
3. 変更不要ならskip
4. 変更必要ならapply
5. Post Evidence取得
6. Expected State検証
7. Releaseへ結果を紐付け

## 6.7 NIM更新フロー

```text
Release Definition
      ↓
NIM pre-check
      ↓
Pre-update Evidence
      ↓
TL / SP / PTF適用
      ↓
Reboot if required
      ↓
Post-update Evidence
      ↓
AIX level / fileset / errpt validation
      ↓
Application Deploy / Test
```

NIM操作そのものを成功条件とせず、更新後Evidenceとテスト結果までを一つの工程とする。

## 6.8 Promotion

Promotion対象は同一Releaseであることを保証する。

DEV -> QA -> PROD-equivalentで、以下を固定または明示的に差分管理する。

- AIX level
- PTF / TL / SP bundle
- Application artifact
- IaC commit
- Test suite
- Rule set
- Approved exceptions

## 6.9 Promotion Gate

昇格可否はDeterministic条件で評価する。

PowerHAについては次の2種類を明確に区別する。

- `PowerHA Configuration Verification`: cluster verify / sync等による構成整合性の検証
- `PowerHA Failover Test`: Resource Groupの実際のfailover / failbackによる動作検証

例:

- required tests = PASS
- critical findings = 0
- unresolved high findings = 0 または承認済み例外
- evidence coverage >= threshold
- AIX target level = expected
- application artifact hash = expected
- PowerHA Configuration Verification = PASS（PowerHA対象Releaseでは必須）
- PowerHA Failover Test = PASS（`require_powerha_failover = true` のReleaseのみ必須）

したがって、PowerHAを対象とするReleaseのGateは概念的に以下となる。

```text
Required Tests == PASS
AND Critical Findings == 0
AND Unapproved High Findings == 0
AND Evidence Coverage >= threshold
AND AIX Target Level == Expected
AND Artifact Hash == Expected
AND PowerHA Configuration Verification == PASS
AND (
    RequirePowerHAFailover == false
    OR PowerHA Failover Test == PASS
)
```

LLMのRisk SummaryはGate入力ではなく、Human Review支援情報とする。

## 6.10 mksysb / Golden Release

昇格成功後、必要な環境でNIMからmksysbを取得する。

mksysb取得時に以下を固定する。

- release_id
- environment
- oslevel
- PTF bundle
- application version
- IaC commit
- test result
- evidence snapshot
- mksysb object / storage reference
- creation timestamp

これをGolden Releaseとして次回更新前比較・復旧計画に利用する。

## 6.11 Evidence Gate

工程ごとに最低Evidence条件を定義する。

### Storage
- required path count
- PVID consistency
- reserve policy / MPIO attributes

### LVM / FS
- VG mode
- major number consistency
- auto varyon policy
- JFS2 mount policy

### PowerHA Configuration Verification
- cluster verify / sync
- RG state
- shared resources

### PowerHA Failover Test
- failover result
- failback result
- Application Controller start/stop result
- failover / failback後のRGおよびApplication状態

### NIM Update
- expected oslevel
- expected fileset state
- update exit status
- post-update errpt review

### Release
- artifact hash
- test suite result
- promotion criteria

## 6.12 再実行とRollback

- Step単位で状態を保持する
- 既完了StepはEvidenceで再確認する
- Design / Release / Plan変更時は再承認する
- 手動変更はDriftとして検出する

Rollbackは次を区別する。

- Automatic rollback
- Compensating action
- Application rollback
- alt disk / NIM based recovery
- mksysb recovery
- Manual recovery

AIX更新では「元に戻す」操作を安易に自動化せず、Golden Releaseと復旧手段を事前に持つ。

## 6.13 GitHub連携

- Design / Rule / Schema / Release template変更はPR
- CIでSchema、Rule、Plan、Regressionを検証
- Plan差分とPromotion条件をレビュー
- 実行結果とEvidence ReportをRelease / commitへ紐付ける
- Golden Release更新は承認履歴を残す

## 6.14 Bounded Authorization / Fail-Stop Execution

ExecutorはApprovalを「目的」ではなく「明示された操作」に対する権限として扱う。

例:

```text
Plan Step:
  action: apply_ptf_bundle
  target: aix-dev-01
  expected_result: oslevel == expected && required_filesets == committed
  retry_policy: max_attempts=1 unless explicitly approved
  diagnostic_allowlist:
    - oslevel -s
    - lslpp -L
    - errpt -a
  stop_condition:
    - unexpected_exit_code
    - expected_state_not_reached
    - unplanned_reboot_required
```

実行後の処理:

```text
APPROVED STEP
    ↓
EXECUTE
    ↓
CAPTURE OBSERVED EVIDENCE
    ├─ Expected Result
    │      ↓
    │   NEXT APPROVED STEP
    │
    └─ Unexpected Result
           ↓
        FAIL-STOP
           ↓
   READ-ONLY DIAGNOSTIC ALLOWLIST
           ↓
         REPORT
           ↓
        NEW PLAN
           ↓
      NEW APPROVAL
```

Unexpected Result発生後に、ExecutorまたはAgentが独断で以下へ遷移してはならない。

- 別コマンドによる修復
- package install / upgrade / uninstall
- PATH / Service / Shell / Registry変更
- reboot
- failover / failback
- rollback / recovery
- 別Provider / Adapterへの切替
- 追加state-changing retry

これらが必要なら新しいPlanとして扱う。

Read-only診断は、事前に`diagnostic_allowlist`へ定義された範囲でのみ継続できる。

## 6.15 Retry Semantics

Retryはエラー時の自由な試行錯誤ではなくPlanの一部とする。

- retry対象Actionを明示する
- max attemptsを明示する
- retry前に再確認すべきpreconditionを定義する
- 新しいEvidenceまたは前提変化がないad-hoc retryを禁止する
- retry policyを超えた場合は`STOPPED_RETRY_EXHAUSTED`としてEscalationする

Agentが同一ブロッカーに対して方法だけを変えながら探索を継続することをRetryとはみなさない。その場合は新しい仮説として再Plan・再承認を要求する。
