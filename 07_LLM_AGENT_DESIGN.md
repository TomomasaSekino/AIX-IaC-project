# 7. LLM Agent Design

## 7.1 原則

LLMは実行エンジンではなく、**設計理解、変更影響分析、Evidence解釈、テスト失敗分析、昇格リスク要約、学習候補生成**を担当する。

確定判定はRule Engine、実行はExecutor/NIM/Deploy Adapter、最終承認はHuman Gateが担う。

## 7.2 LLM介在点

### 1. Design Review
Power基盤全体の論理設計をレビューする。

参照:
- Design
- Topology Graph
- Deterministic Findings
- Knowledge RAG
- Golden Patterns

主な観点:
- Dual VIOS / NPIV / SEA / SAN冗長性
- Shared Disk / PowerHA依存関係
- PowerVS live検証範囲とVirtual Reference範囲の整合性

### 2. Pre-change Impact Review
Release適用前に、変更内容と過去Caseを比較する。

入力:
- target AIX level
- TL / SP / PTF bundle
- Middleware version
- Application artifact
- current Golden Release
- similar Case

出力:
- 変更影響候補
- 過去の類似問題
- 必要テスト候補
- 追加Evidence候補
- 不確実性

### 3. Post-change Evidence Analysis
NIM更新やApplication Deploy後の差分を意味付けする。

Deterministic Comparatorが抽出した差分を基に、以下を整理する。

- 想定差分
- 想定外差分
- 要確認差分
- 過去Caseとの類似性

差分抽出自体をLLMへ委ねない。

### 4. Test Failure Analysis
Test失敗時に原因候補を順位付けする。

例:
- Application変更起因
- AIX/PTF変更起因
- Middleware互換性
- MPIO/LVM/PowerHA状態差
- 環境固有差分

LLMは「原因確定」ではなく仮説と追加Evidenceを提示する。

### 5. Promotion Risk Summary
Rule/Test/Evidence Gateの結果を人間向けに要約する。

例:

- 全必須テストPASS
- Critical Findingなし
- DEV Goldenとの差分2件
- 1件は承認済み例外
- 過去Caseとの関連1件
- QAで追加すべき確認1件

LLMのSummary自体はPromotion可否を決定しない。

### 6. Learning Candidate
Promotion成功、Test failure、障害、是正、人間訂正から以下を生成する。

- Knowledge候補
- Rule候補
- Regression Case候補
- Golden Baseline更新候補
- Golden Release metadata候補
- Parser / Retrieval改善候補

## 7.3 Agents

### Orchestrator Agent
要求、Release、現在工程を解釈し、必要なRule、Retriever、Agentを選択する。

### Design Review Agent
Power基盤全体の設計意図と冗長性をレビューする。

### Change Impact Agent
NIM更新、PTF、Application変更の組み合わせを過去Caseと比較する。

### Evidence Analysis Agent
Current Evidence、Golden Evidence、simulated upper-layer Evidenceを出自付きで比較する。

### Test Failure Agent
失敗結果から仮説と追加確認Evidenceを生成する。

### Promotion Review Agent
確定Gate結果を変更リスクとして要約する。

### Learning Agent
人間承認済み結果から学習候補を生成する。

### Report Agent
Rule、Evidence、Case、Agent結果を統合し、重複と矛盾を整理する。

## 7.4 Agent Contract

すべてのAgent出力に最低限以下を含める。

```yaml
agent_id: string
task_id: string
release_id: string | null
input_refs: []
conclusions: []
evidence_refs: []
rule_refs: []
case_refs: []
evidence_origin_summary: []
assumptions: []
uncertainties: []
recommended_actions: []
prohibited_actions: []
```

## 7.5 Evidence Originの扱い

LLMはEvidenceの出自を必ず考慮する。

- `live + verified`: 強い根拠
- `simulated + assumed`: 仮想上位設計上の根拠
- `documented`: 設計/知識としての根拠
- `unverified`: 断定材料にしない

例えばHMC/VIOS模擬Evidenceから得た情報を「PowerVS実機で確認済み」と表現してはならない。

## 7.6 Tool Use

Agentが利用できるTool:

- Design Reader
- Release Reader
- Rule Query
- Knowledge Retriever
- Evidence Retriever
- Case Retriever
- Topology Query
- Plan Diff
- Evidence Diff
- Test Result Reader
- Report Writer

Agentが直接利用できないTool:

- HMC change execution
- VIOS change execution
- AIX root execution
- NIM change execution
- SAN change execution
- PowerHA destructive execution
- Secret Store raw access
- Promotion state mutation

## 7.7 Incident Scope

本プロジェクトにおけるインシデント対応は限定する。

対象:
- 過去Case検索
- Current vs Golden比較
- 原因候補
- 追加確認Evidence
- 是正後の知識化

非対象:
- ITSM ticket lifecycle
- 自律Incident Commander
- ServiceNow代替
- 無承認自動復旧

## 7.8 失敗時動作

- Evidence不足: 追加収集候補を提示
- live/simulated競合: 出自差を明示
- Parser失敗: Raw参照を限定し人間確認へ
- RuleとLLM不一致: Ruleを確定事項として優先し、LLMは異議理由を説明
- Test結果とEvidenceが矛盾: Promotionを止めて人間レビューへ
- 根拠なし高リスク提案: 棄却
