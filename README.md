# AIX Engineering Intelligence Platform — Design v0.2

AIX / PowerVM / VIOS / SAN / PowerHA を対象に、IaC・NIM・リリース昇格・Evidence RAG・LLMを組み合わせ、AIX基盤エンジニアリングを再現可能かつ学習可能なプロセスへ変換する個人研究プロジェクトです。

GitHub公開は研究成果を外部化する手段であり、プロジェクトの目的そのものではありません。中心となる研究サイクルは、**仮説 → 設計 → 実装 → 実機検証 → Evidence → 評価 → 設計更新**です。

## v0.2で追加した中核方針

1. **Power基盤全体を設計対象とする**  
   HMC / PowerVM / Dual VIOS / NPIV / SEA / FC Fabric / SAN / AIX / PowerHA を一つの論理構成として扱います。

2. **PowerVSでは検証可能範囲を明示する**  
   PowerVS上では、PowerVMより下の物理基盤、HMC、VIOS、SAN Fabric等はIBM管理領域です。したがって、AIX LPAR、Volume、MPIO、LVM、JFS2、PowerHA、NIM、Evidence取得を実機検証し、上位Power基盤層は仮想上位設計と模擬Evidenceで補完します。

3. **既存IaC資産を実行部品として再利用する**  
   AIX、HMC、VIOS、PowerHA、PowerVS向けの既存Ansible CollectionやTerraform Provider/Moduleを再実装するのではなく、統合制御・検証・Evidence化・学習を独自価値とします。

4. **NIMをAIX Lifecycle Engineとして組み込む**  
   TL / SP / PTF適用、mksysb、復旧ポイント管理など、OSライフサイクルをリリースプロセスへ統合します。

5. **DEV → QA → PROD相当のPromotion Pipelineを設ける**  
   AIX更新、アプリケーション成果物、テスト、Evidenceを一つのReleaseとして扱い、各環境で同一条件を検証して昇格させます。

6. **mksysbをGolden Releaseの復旧ポイントとして扱う**  
   昇格後に取得したmksysbを、Release ID、AIXレベル、PTF bundle、Application Version、Test Result、Evidence Snapshotと関連付けます。

7. **RAGを3層に分離する**  
   Knowledge RAG、Evidence RAG、Case RAGを分け、実測Evidenceと模擬Evidenceを明確に識別します。

8. **LLMは分析・推論・学習に寄せる**  
   変更前影響レビュー、Evidence差分解釈、テスト失敗時の原因候補、追加確認、昇格時リスク要約、学習候補生成を担当します。確定判定と実行はRule Engine / Executor / Human Gateが担います。

9. **インシデント管理プラットフォーム化は今回の範囲外**  
   過去事例検索や調査支援は行いますが、自律Incident Commander、ITSM、ServiceNow代替を目標にはしません。

## Human / AI Collaboration

研究と実装は、**Human → ChatGPT → Codex → Claude Code** を基本分業とします。GitHubをAI間の共有外部記憶かつSource of Truthとして使い、会話履歴だけに依存した引き継ぎは行いません。

- Human: Research Owner / Chief Engineer — Why、優先順位、リスク受容、最終判断
- ChatGPT: Research Architect / Orchestrator — What、要件、Architecture、ADR、Task/Acceptance Criteria
- Codex: Implementation Engineer — How、Code、Test、CI、Evidence、Pull Request
- Claude Code: Independent Review / Assurance Engineer — Acceptance Criteria、設計整合、Regression、安全性、Evidenceの独立レビュー

共通ルールは `AI_COLLABORATION.md`、Codex向け入口は `AGENTS.md`、Claude Code向け入口は `CLAUDE.md` に定義します。

## 設計文書

| 文書 | 内容 |
|---|---|
| `AI_COLLABORATION.md` | Human / ChatGPT / Codex / Claude Codeの役割、権限、引き継ぎ、Source of Truth |
| `01_VISION_AND_SCOPE.md` | 研究目的、対象、PowerVS境界、非対象 |
| `02_SYSTEM_REQUIREMENTS.md` | 機能・非機能・制約・受入条件 |
| `03_ARCHITECTURE.md` | Power基盤、PowerVS検証層、制御・Evidence・昇格アーキテクチャ |
| `04_DOMAIN_AND_DATA_MODEL.md` | Powerトポロジー、Release、Golden Release、Evidenceモデル |
| `05_EVIDENCE_RAG_DESIGN.md` | Knowledge / Evidence / Case RAG、実測・模擬Evidence、検索 |
| `06_IAC_EXECUTION_DESIGN.md` | IaC、NIM、PowerHA、実行・Evidence Gate |
| `07_LLM_AGENT_DESIGN.md` | LLM責務、変更前・変更後・テスト・昇格での介在点 |
| `08_LEARNING_LOOP_DESIGN.md` | Golden、Rule、Regression、Release学習ループ |
| `09_SAFETY_AND_GOVERNANCE.md` | 承認、秘密情報、実測/模擬Evidence管理 |
| `10_TEST_AND_EVALUATION.md` | PowerVS実機、模擬上位層、Promotion Pipeline評価 |
| `11_RELEASE_PROMOTION_DESIGN.md` | NIM + Application Deploy + Test + Promotion + mksysb |
| `schemas/` | 機械可読スキーマ |
| `examples/` | 正常・異常・学習例 |
| `adr/` | 主要設計判断 |
| `roadmap/ROADMAP.md` | 実装・研究ロードマップ |

## 独自価値

この研究の焦点は「AIXをTerraformやAnsibleで動かすこと」そのものではありません。

**Power基盤全体の設計意図を保持し、既存IaCを統合して実行し、NIMによるOSライフサイクルとアプリケーションリリースを同じPromotion Pipelineで検証し、その結果をEvidence RAGとLLMへ還元すること**を中核とします。
