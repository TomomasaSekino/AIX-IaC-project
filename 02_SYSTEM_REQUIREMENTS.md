# 2. System Requirements

## 2.1 機能要件

### FR-001 Design as Code
PowerVM、VIOS、SAN、AIX、PowerHA、NIM、Release Promotionの設計を機械可読形式で定義できること。

### FR-002 Schema Validation
必須項目、型、列挙値、参照整合性を実行前に検査できること。

### FR-003 Topology Construction
LPARからVIOS、FC、LUN、hdisk、VG、FS、Resource Group、Applicationまでの依存関係をグラフ化できること。

### FR-004 Platform Boundary Modeling
PowerVS上でIBM管理となるPowerVM/HMC/VIOS/SAN層と、利用者が検証可能なAIX/PowerHA/NIM層を明示的に分離できること。

### FR-005 Simulated Upper-Layer Evidence
HMC、VIOS、SANについて、匿名化・合成した模擬Evidenceを実測Evidenceと区別して保持できること。

### FR-006 Plan Generation
設計からHMC、VIOS、AIX、PowerHA、NIM、Release PromotionのPlanを生成できること。

### FR-007 Deterministic Review
冗長性、パス数、auto varyon、major number、共有ディスク、PowerHA管理属性、Release必須条件などをルールで検査できること。

### FR-008 Human Approval
生成Plan、変更差分、リスク、昇格条件を提示し、承認済みPlanのみ実行可能にすること。

### FR-009 Controlled Execution
実行対象、順序、再実行条件、タイムアウト、失敗時停止条件を制御できること。

### FR-010 Existing IaC Reuse
AIX、HMC、VIOS、PowerHA、PowerVS向けの既存Terraform/Ansible資産を実行Adapterとして利用可能にすること。

### FR-011 NIM Lifecycle
NIMを介してAIX TL / SP / PTF適用、ソフトウェア配布、mksysb取得をRelease Workflowへ組み込めること。

### FR-012 Release Definition
AIXレベル、PTF bundle、Middleware、Application artifact、IaC version、Test suite、Evidence baselineを一つのReleaseとして定義できること。

### FR-013 Promotion Pipeline
DEV -> QA -> PROD相当の各環境へ、同一Releaseを段階的に昇格できること。

### FR-014 Promotion Gate
Test Result、Rule Finding、Evidence差分、例外承認状態に基づき、確定的な昇格条件を評価できること。

### FR-015 Golden Release
昇格成功後のmksysb、Release ID、AIXレベル、PTF、Application version、Evidence Snapshotを関連付けて保存できること。

### FR-016 Evidence Collection
各工程の前後でHMC、VIOS、AIX、PowerHA、NIM、SAN、Release関連Evidenceを収集できること。

### FR-017 Evidence Origin Classification
Evidenceごとに `live / simulated / documented` と `verified / assumed / unverified` を保持できること。

### FR-018 Evidence Normalization
生ログから対象、属性、状態、関係、時刻、工程、Releaseを抽出し構造化できること。

### FR-019 Three-layer RAG
Knowledge RAG、Evidence RAG、Case RAGを分離して検索できること。

### FR-020 Hybrid Retrieval
Structured、Keyword、Vector、Topology Graphを組み合わせて検索できること。

### FR-021 Golden Comparison
今回Evidenceと、対象Release/構成に対応するGolden Evidenceを比較できること。

### FR-022 Evidence-grounded Answer
LLMの回答にEvidence ID、Rule ID、Case ID、Release IDを付与できること。

### FR-023 Pre-change Review
LLMが変更前に過去事例、構成差分、既知リスク、必要テスト候補を提示できること。

### FR-024 Post-change Analysis
LLMがPTF適用後やApplication Deploy後のEvidence差分を解釈できること。

### FR-025 Test Failure Analysis
テスト失敗時にLLMが原因候補を順位付けし、追加確認Evidenceを提案できること。

### FR-026 Promotion Risk Summary
昇格前にLLMが確定Rule結果とEvidence差分を基にリスク要約を生成できること。ただし昇格可否はLLM単独で決定しないこと。

### FR-027 Learning Candidate Generation
正常構築、障害、是正、人間レビュー、Release結果から、Knowledge、Rule、Regression、Golden更新候補を生成できること。

### FR-028 Report Generation
設計レビュー、構築結果、Release結果、差分、未解決事項、推奨確認をMarkdownまたはJSONで出力できること。

## 2.2 非機能要件

### NFR-001 再現性
同一設計・同一入力から同一Planと同一Deterministic Findingを得られること。

### NFR-002 監査性
Design、Plan、Release、承認、実行、NIM操作、Evidence、LLM入出力、mksysb参照を追跡できること。

### NFR-003 安全性
LLMが認証情報を閲覧・出力せず、HMC/VIOS/AIX/NIM/PowerHAへの直接実行権限を持たないこと。

### NFR-004 説明可能性
各FindingとLLM結論が、Rule、Evidence、Case、Releaseまで逆引き可能であること。

### NFR-005 可搬性
ローカル、CI、PowerVS、将来のオンプレPower環境へ段階的に移植可能であること。

### NFR-006 拡張性
新しいAIX、VIOS、PowerHA、NIM、Storage、FC、Deploy製品向けAdapter/Parser/Ruleを追加可能であること。

### NFR-007 データ保護
ホスト名、IP、WWPN、ユーザー名、組織情報等を匿名化またはマスキング可能であること。

### NFR-008 Evidence Integrity
Raw Evidenceは改変せず、Hashと取得条件を保持すること。

### NFR-009 Origin Integrity
実測Evidenceと模擬EvidenceをUI、API、検索結果、LLM Context上でも明確に区別できること。

## 2.3 制約

- PowerVSではHMC、VIOS、物理SAN Fabricを利用者が直接管理できないため、当該層はVirtual Reference Platformと模擬Evidenceで補完する
- 実機がないCIではSample/Simulated EvidenceとPlan生成を検証対象とする
- 実行コマンドは製品・バージョン差をAdapterで吸収する
- LLM出力は非決定的なため、確定判定や昇格条件に単独利用しない
- IBM等の著作物は転載せず、自作の要約、Rule、Sampleを格納する
- 公開リポジトリには機密情報を保存しない
- ITSM / ServiceNow代替は本プロジェクトの範囲外とする

## 2.4 主要ユースケース

1. Virtual Reference PlatformとしてDual HMC / Dual VIOS / Dual Fabric構成を設計する
2. PowerVS上へAIXをTerraformで構築する
3. AIX実機Evidenceと設計値を比較する
4. 2ノードPowerHA + Shared Volumeを構築・検証する
5. NIMからPTF / TL / SPをDEVへ適用する
6. Application artifactをDEVへDeployする
7. PTF適合・回帰・PowerHA試験を実行する
8. DEV合格ReleaseをQAへ昇格する
9. QA合格ReleaseをPROD相当へ昇格する
10. 昇格後にNIMからmksysbを取得しGolden Release化する
11. テスト失敗時にEvidence RAGから過去事例と追加確認を提示する
12. 構築・更新結果を次回Rule/Regression/Goldenへ反映する

## 2.5 初期受入条件

- PowerVS検証境界とVirtual Reference Platformが設計上分離される
- live / simulated Evidenceが混同されない
- AIX 1台のIaC作成・Evidence取得・完全削除が再現できる
- 2ノード構成でShared Volume / MPIO / VG / JFS2 / PowerHA Evidenceを追跡できる
- NIMによるAIX更新をReleaseに紐付けられる
- ReleaseをDEV -> QAへ昇格できる
- Promotion GateがLLMではなくRule/Test/Evidenceで判定される
- mksysbをGolden Releaseへ関連付けられる
- LLM回答に根拠Evidenceが付く
- 過去障害をCI Regressionで再検出できる
