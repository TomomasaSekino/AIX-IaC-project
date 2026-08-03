# AIX HA Engineering Intelligence Platform — Design v0.1

PowerVM / VIOS / SAN / AIX / PowerHA の構築を自動化し、構築エビデンスを中核資産として蓄積・検索・比較・再利用する、自己成長型エンジニアリング基盤の初期設計です。

## 設計の中心思想

1. **Evidence RAGを中心に置く**  
   設計書や手順書だけでなく、HMC・VIOS・AIX・PowerHA・SANの実測エビデンスを、正常系・異常系・是正後の状態として蓄積する。

2. **確定判定と推論を分離する**  
   JSON Schema、ルール、差分比較、トポロジー検査で判定可能な項目はコードで処理し、LLMは文脈理解・類似事例検索・原因候補・追加確認・説明生成を担う。

3. **構築するほど強くなる**  
   構築結果、人間レビュー、障害、是正、フェイルオーバー試験を、ゴールデンエビデンス、ルール、回帰テスト、検索知識へ昇格させる。

4. **LLMに直接変更させない**  
   LLMは計画・レビュー・分析・提案を行う。実行は承認済みPlanを非LLM実行器が行い、全操作を監査可能にする。

## 文書構成

| 文書 | 内容 |
|---|---|
| `01_VISION_AND_SCOPE.md` | 目的、価値、対象、非対象 |
| `02_SYSTEM_REQUIREMENTS.md` | 機能・非機能・制約・受入条件 |
| `03_ARCHITECTURE.md` | 全体構成、主要コンポーネント、処理フロー |
| `04_DOMAIN_AND_DATA_MODEL.md` | ドメインモデル、エビデンスモデル、関係 |
| `05_EVIDENCE_RAG_DESIGN.md` | 収集、正規化、索引、検索、比較、引用 |
| `06_IAC_EXECUTION_DESIGN.md` | 生成、承認、実行、検証、再実行、ロールバック |
| `07_LLM_AGENT_DESIGN.md` | エージェント責務、入出力、禁止事項 |
| `08_LEARNING_LOOP_DESIGN.md` | 学習候補生成、評価、昇格、回帰試験 |
| `09_SAFETY_AND_GOVERNANCE.md` | 権限、秘密情報、監査、安全制御 |
| `10_TEST_AND_EVALUATION.md` | テスト戦略、品質指標、評価方法 |
| `schemas/` | 機械可読スキーマ |
| `examples/` | 正常・異常・学習例 |
| `adr/` | 主要設計判断 |
| `roadmap/ROADMAP.md` | MVPから実機連携までの段階計画 |

## 想定成果

- PowerVM / VIOS / SAN / AIX / PowerHA構築時間の短縮
- 構築後確認の標準化と見落とし削減
- 正常系との差分検出
- 過去障害・是正事例の即時検索
- 追加確認コマンドの提示
- 再発防止ルールと回帰テストの自動生成支援
- 熟練者の暗黙知を組織資産へ変換
