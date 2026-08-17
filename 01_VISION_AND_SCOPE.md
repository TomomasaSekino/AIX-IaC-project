# 1. Vision and Scope

## 1.1 ビジョン

AIX / Power基盤の設計・構築・更新・検証・昇格を、IaC、NIM、Evidence RAG、LLMにより再現可能なエンジニアリングプロセスへ変換する。

本プロジェクトはポートフォリオ作成を主目的とせず、AIX / Power基盤へ現代的なIaC・AI技術を適用した場合、どこまで構築時間短縮、品質向上、知識継承、リリース安全性を実現できるかを検証する個人研究である。

研究サイクルは以下を基本とする。

`仮説 -> 設計 -> 実装 -> 実機/模擬検証 -> Evidence -> 評価 -> 設計更新`

## 1.2 解決する課題

- Power基盤の構築品質が担当者の経験と記憶に依存する
- HMC、VIOS、SAN、AIX、PowerHAの証跡が分断される
- 手順書どおりでも実環境が設計状態に一致しているとは限らない
- PTF / TL / SP適用とアプリケーション変更の適合性確認が属人的になりやすい
- DEVで確認した変更をQA、PRODへ同一条件で昇格させる仕組みがAIX標準では弱い
- NIMによるOSライフサイクルとアプリケーションリリースが別々に管理されやすい
- 過去の正常Evidence、障害、是正、レビュー判断を次回構築へ十分再利用できない
- 熟練者レビューが毎回ゼロから繰り返される

## 1.3 主要価値

### Power基盤全体を扱う
AIX OSだけでなく、HMC / PowerVM / Dual VIOS / NPIV / SEA / FC Fabric / SAN / AIX / PowerHAまでを一つの論理トポロジーとして設計する。

### 実行部品を再発明しない
既存のTerraform Provider / Module、Ansible Collection、NIM等を実行部品として利用し、独自価値を統合制御、Evidence検証、Promotion、LLM支援へ置く。

### Evidence中心の品質保証
設計値、Plan、実測Evidence、模擬上位層Evidence、Golden Baselineを比較し、構成漏れ、冗長性不備、リリース差分を検出する。

### AIX LifecycleとApplication Releaseの統合
NIMによるPTF / TL / SP適用と、アプリケーション成果物のデプロイを同じRelease単位で追跡し、テスト合格後に次環境へ昇格する。

### Golden Release
昇格後にmksysbを取得し、AIXレベル、PTF bundle、Application Version、Test Result、Evidence Snapshotと関連付ける。

### LLMによる知的支援
変更前影響分析、Evidence差分解釈、テスト失敗時の原因候補、追加確認、昇格時リスク要約、学習候補生成を行う。

## 1.4 PowerVS検証境界

PowerVSではPowerVM基盤を利用するが、物理Power System、HMC、VIOS、SEA、FC Fabric等の管理はクラウドサービス側に属する。

したがって研究では二層に分ける。

### Virtual Reference Platform
実務相当の上位Power基盤を論理設計する。

- Dual HMC
- Power Systems
- Dual VIOS
- SEA redundancy
- NPIV / vSCSI
- Dual FC Fabric
- Shared SAN
- AIX LPAR
- PowerHA

HMC / VIOS / SAN層は匿名化・合成した模擬Evidenceで検証する。

### PowerVS Live Validation Platform
PowerVSで実際に検証できる層。

- AIX VSI / LPAR
- CPU / Memory / Network
- PowerVS Volume
- AIX hdisk / MPIO
- PVID / VG / LV / JFS2
- Enhanced Concurrent VG
- PowerHA
- NIM
- Failover / Failback
- Evidence収集

## 1.5 RAG対象

RAGは三層に分ける。

1. `Knowledge RAG`: 設計原則、運用知識、製品知識
2. `Evidence RAG`: 実測・模擬・文書由来の構成Evidence
3. `Case RAG`: 正常構築、障害、原因、是正、設計判断、回帰試験

実測Evidenceと模擬Evidenceは混同せず、出自と検証状態を必ず保持する。

## 1.6 Release Promotion対象

DEV -> QA -> PROD相当の環境昇格を研究対象とする。

各Releaseには最低限以下を含める。

- AIX target level
- PTF / TL / SP bundle
- Middleware version
- Application artifact version
- IaC version
- Test suite
- Evidence baseline
- Approval status
- mksysb reference

## 1.7 初期非対象

- LLMによる無承認の本番変更
- 完全自律の障害復旧
- ServiceNow等のITSMプラットフォーム代替
- 自律Incident Commander
- SANストレージ固有APIの全面実装
- FCスイッチ全製品対応
- PowerHA全バージョン完全互換
- 機密Evidenceの公開
- 初期段階でのモデルFine-tuning

障害対応については、過去事例検索、Evidence比較、原因候補、追加確認支援までを対象とする。

## 1.8 成功条件

- Power基盤全体の論理設計とPowerVS実機検証境界が明確である
- 実測Evidenceと模擬Evidenceが区別される
- AIX構築・更新がIaC / NIMで再現できる
- PTF適用とApplication Deployを同じReleaseとして追跡できる
- DEV -> QA -> PROD相当のPromotion Gateを実装できる
- 昇格後mksysbとGolden Releaseを関連付けられる
- 指摘がRule / Evidence / Caseの根拠付きで再現可能である
- 過去問題をRegression Testとして再検出できる
- 構築・更新ごとにKnowledge / Golden / Rule候補が増える
