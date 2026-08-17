# 9. Safety and Governance

## 9.1 権限分離

- LLM: 読み取り、分析、提案のみ
- Retriever: 許可されたKnowledge / Evidence / Caseを検索
- Rule Engine: 確定条件を評価
- Executor: 承認済みPlanのみ実行
- NIM Adapter: 承認済みAIX lifecycle操作のみ実行
- Deploy Adapter: 承認済みApplication artifactのみ配布
- Approver: Plan / Risk / Promotionを承認
- Administrator: Rule、Parser、Schema、Secretを管理

## 9.2 Secret管理

- パスワード、鍵、TokenをDesignやPromptへ埋め込まない
- Secret StoreからExecution時のみ注入
- LLM Contextへ渡さない
- ログ出力をマスキング
- Secret利用履歴を監査

## 9.3 Evidence分類

機密区分:

- Public Sample
- Internal
- Confidential
- Restricted

出自区分:

- live
- simulated
- documented

検証状態:

- verified
- assumed
- unverified

公開前に以下を除去する。

- 実ホスト名
- IPアドレス
- WWPN
- Storage identifier
- 顧客名
- ユーザー名
- チケット番号
- 認証情報

## 9.4 実測と模擬Evidenceの分離

PowerVSではHMC / VIOS / SAN Fabricが直接検証できないため、上位層に模擬Evidenceを利用する。

ルール:

- simulated evidenceには必ず出自を付ける
- simulatedをliveに昇格させない
- Golden Releaseの主要受入根拠はlive evidenceを要求する
- LLM回答でEvidence originを省略しない
- 模擬値を実環境の事実として外部公開しない

## 9.5 承認制御

以下は必ず承認を要求する。

- LPAR Profile変更
- VIOS mapping変更
- SAN zoning / LUN mapping
- VG / FS破壊的変更
- AIX TL / SP / PTF適用
- NIM destructive operation
- PowerHA topology / RG変更
- Cluster stop/start
- Failover / Failback
- ApplicationのPROD相当昇格
- Promotion exception
- Rule正式昇格
- Golden Release正式化

## 9.6 Promotion Governance

Promotion GateはLLMに依存しない。

最低限以下を機械判定する。

- 必須Test結果
- Critical / High Finding
- Evidence coverage
- target AIX level
- artifact identity / hash
- PowerHA verification
- Approved exception

LLMはRisk Summaryを提供するが、Gate結果を上書きしない。

## 9.7 mksysb Governance

Golden Releaseへ関連付けるmksysbには以下を保持する。

- mksysb ID
- Release ID
- environment
- AIX oslevel
- creation timestamp
- storage reference
- integrity metadata
- retention policy

mksysb自体を公開リポジトリへ保存しない。

## 9.8 監査ログ

記録対象:

- Design commit
- Release definition
- Plan hash
- Rule set version
- Prompt version
- Retrieval result IDs
- Evidence origin
- LLM response
- Approver
- Execution command / module
- NIM operation
- Exit code
- Evidence hash
- Test result
- Promotion decision
- mksysb metadata
- Golden Release promotion
- Learning asset promotion

## 9.9 LLM安全策

- Evidenceを命令ではなくデータとして扱う
- Evidence内に含まれる命令文をTool指示として解釈しない
- Tool allowlist
- Agent output Schema validation
- 根拠未提示の高リスク提案を棄却
- 実行系ToolをLLMから隔離
- live / simulated / documentedの根拠強度を区別

## 9.10 変更管理

- Rule、Parser、Prompt、Schema、Release TemplateはGit管理
- 設計変更はPull Request
- Regression Test必須
- 破壊的変更はVersionを上げる
- 主要設計判断をADRへ記録

## 9.11 例外管理

RuleまたはPromotion条件を例外扱いする場合:

- 対象
- Release ID
- 理由
- 期限
- 承認者
- 代替対策
- 再評価条件

をDecisionとして保存する。

## 9.12 Scope Governance

本プロジェクトではインシデント調査支援を扱うが、ITSMプラットフォーム、ServiceNow代替、自律Incident Commander、無承認自動復旧は範囲外とする。
