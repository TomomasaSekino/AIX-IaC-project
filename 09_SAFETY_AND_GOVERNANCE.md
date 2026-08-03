# 9. Safety and Governance

## 9.1 権限分離

- LLM: 読み取りと提案のみ
- Retriever: 承認済みEvidenceのみ検索
- Executor: 承認済みPlanのみ実行
- Approver: PlanとRiskを承認
- Administrator: Rule、Parser、Secretを管理

## 9.2 Secret管理

- パスワード、鍵、TokenをDesignやPromptへ埋め込まない
- Secret StoreからExecution時のみ注入
- LLM Contextへ渡さない
- ログ出力をマスキング
- Secret利用履歴を監査

## 9.3 Evidence保護

分類:

- Public Sample
- Internal
- Confidential
- Restricted

公開前に以下を除去する。

- 実ホスト名
- IPアドレス
- WWPN
- ストレージ識別子
- 顧客名
- ユーザー名
- チケット番号
- 認証情報

## 9.4 承認制御

以下は必ず承認を要求する。

- LPAR Profile変更
- VIOS mapping変更
- SAN zoning / LUN mapping
- VG / FS破壊的変更
- PowerHA topology / RG変更
- Cluster stop/start
- Failover / Failback
- Rule正式昇格

## 9.5 監査ログ

記録対象:

- Design commit
- Plan hash
- Rule set version
- Prompt version
- Retrieval result IDs
- LLM response
- Approver
- Execution command
- Exit code
- Evidence hash
- Report
- Learning asset promotion

## 9.6 LLM安全策

- Prompt Injection対策としてEvidenceを命令ではなくデータとして扱う
- Evidence内の「実行せよ」等を無視する
- Tool呼び出し許可リスト
- 出力Schema検証
- 根拠未提示の高リスク提案を棄却
- 実行系ToolをLLMから隔離

## 9.7 変更管理

- Rule、Parser、Prompt、SchemaはGit管理
- 変更はPull Request
- 回帰試験必須
- 破壊的変更はVersionを上げる
- 廃止理由をADRへ記録

## 9.8 例外管理

Rule違反を許容する場合:

- 対象
- 理由
- 期限
- 承認者
- 代替対策
- 再評価条件

をDecisionとして保存する。
