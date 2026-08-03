# 7. LLM Agent Design

## 7.1 原則

LLMは曖昧な文脈理解と説明を担当する。実行、確定判定、秘密情報管理は担当しない。

## 7.2 エージェント

### Orchestrator Agent
目的を解釈し、必要なRule、Retriever、専門Agentを選択する。

入力:
- ユーザー要求
- Design
- Current Phase

出力:
- Task Plan
- 必要Evidence
- 呼び出すAgent

### Design Review Agent
設計意図、冗長性、運用性、障害時挙動をレビューする。

参照:
- Design
- Deterministic Findings
- Golden Patterns
- 過去Decision

禁止:
- 根拠なしに製品仕様を断定
- 実行コマンドを承認済み扱いする

### Evidence Analysis Agent
今回Evidenceと正常系、異常系、設計値を比較する。

出力:
- 確定差分
- 類似事例
- 原因候補
- 追加確認
- 信頼度

### Incident Learning Agent
障害、原因、是正、人間レビューから学習候補を生成する。

出力:
- Rule候補
- Knowledge候補
- Regression Case候補
- Golden Baseline更新候補

### Report Agent
複数AgentとRule結果を統合し、重複を排除して報告する。

### Prompt Evaluation Agent
評価データを使い、Prompt変更案を生成する。自動採用は禁止する。

## 7.3 Agent間契約

すべてのAgent出力は構造化JSONとし、最低限以下を含む。

- agent_id
- task_id
- input_refs
- conclusions
- evidence_refs
- rule_refs
- assumptions
- uncertainties
- recommended_actions
- prohibited_actions

## 7.4 Tool Use

Agentが利用できるTool:

- Design Reader
- Rule Query
- Evidence Retriever
- Topology Query
- Plan Diff
- Report Writer

Agentが利用できないTool:

- HMC直接実行
- VIOS直接実行
- AIX root実行
- SAN変更
- Secret Store直接参照

## 7.5 Model選択

- 小型モデル: 分類、要約、タグ付け
- 高性能モデル: 設計レビュー、複数Evidence統合、障害推論
- ローカルモデル: 閉域・機密データ
- 外部API: 匿名化済みデータに限定

## 7.6 失敗時動作

- Evidence不足: 追加収集要求
- 競合Evidence: 競合を明示し断定しない
- Parser失敗: Raw参照を限定し人間確認へ
- RuleとLLM不一致: Ruleを確定事項として優先し、LLMは異議理由のみ提示
