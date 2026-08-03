# 2. System Requirements

## 2.1 機能要件

### FR-001 Design as Code
PowerVM、VIOS、SAN、AIX、PowerHAの設計を機械可読形式で定義できること。

### FR-002 Schema Validation
必須項目、型、列挙値、参照整合性を実行前に検査できること。

### FR-003 Topology Construction
LPARからVIOS、FC、LUN、hdisk、VG、FS、Resource Groupまでの依存関係をグラフ化できること。

### FR-004 Plan Generation
設計からHMC、VIOS、AIX、PowerHAの実行Planを生成できること。

### FR-005 Deterministic Review
冗長性、パス数、auto varyon、major number、共有ディスク、PowerHA管理属性などをルールで検査できること。

### FR-006 Human Approval
生成Planとリスクを提示し、承認済みPlanのみ実行可能にすること。

### FR-007 Controlled Execution
実行対象、順序、再実行条件、タイムアウト、失敗時停止条件を制御できること。

### FR-008 Evidence Collection
各工程の前後でHMC、VIOS、AIX、PowerHA、SAN関連エビデンスを収集できること。

### FR-009 Evidence Normalization
生ログから対象、属性、状態、関係、時刻、工程を抽出し構造化できること。

### FR-010 Evidence RAG
正常系、異常系、是正後、過去案件のエビデンスをハイブリッド検索できること。

### FR-011 Golden Comparison
今回エビデンスと、選択したゴールデンエビデンスを比較できること。

### FR-012 Evidence-grounded Answer
LLMの回答にエビデンスID、ルールID、事例IDを付与できること。

### FR-013 Incident Learning
障害と是正から、ルール候補、検索知識、回帰テスト候補を生成できること。

### FR-014 Rule Promotion
候補ルールをレビュー、テスト、承認後に正式ルールへ昇格できること。

### FR-015 Regression
過去障害が再び検出可能か、CIで継続検証できること。

### FR-016 Report Generation
設計レビュー、構築結果、差分、未解決事項、推奨確認をMarkdownまたはJSONで出力できること。

## 2.2 非機能要件

### NFR-001 再現性
同一設計・同一入力から同一Planと同一判定結果を得られること。

### NFR-002 監査性
設計版、Plan版、承認者、実行履歴、取得証跡、LLM入力・出力を追跡できること。

### NFR-003 安全性
LLMが認証情報を閲覧・出力せず、直接実行権限を持たないこと。

### NFR-004 説明可能性
各Findingは、根拠と判定経路を参照可能であること。

### NFR-005 可搬性
ローカル検証、CI、閉域環境、将来のクラウド実行へ移植可能であること。

### NFR-006 拡張性
新しいAIX、VIOS、PowerHA、ストレージ、FCスイッチ向けParserとRuleを追加可能であること。

### NFR-007 データ保護
ホスト名、IP、WWPN、ユーザー名、組織情報を匿名化またはマスキング可能であること。

### NFR-008 性能
構築中の類似事例検索と差分解析を、実務上待機可能な時間内で返すこと。

## 2.3 制約

- 実機がないCIでは、サンプルエビデンスとコマンド生成を検証対象とする
- 実行コマンドは製品・バージョン差をAdapterで吸収する
- LLM出力は非決定的なため、確定判定に単独利用しない
- IBM等の著作物は転載せず、自作の要約・ルール・サンプルを格納する
- 公開リポジトリには機密情報を保存しない

## 2.4 主要ユースケース

1. 新規2ノードPowerHA環境の設計レビュー
2. LPAR・VIOS・SAN・AIX・PowerHAの段階構築
3. 構築後の正常系比較
4. SANパス不足の原因調査
5. PowerHA verify/sync失敗の類似事例検索
6. フェイルオーバー試験の事前リスク検査
7. 障害からルール・回帰テストを追加
8. 過去構築を次案件の標準テンプレートへ昇格

## 2.5 初期受入条件

- サンプル設計から一貫したPlanが生成される
- サンプル異常構成で主要ルールが検出される
- エビデンスに対象・工程・時刻・出典が付与される
- 類似事例検索結果が根拠付きで返る
- LLM出力から根拠不明の断定を排除できる
- 過去障害をCI回帰試験で再検出できる
