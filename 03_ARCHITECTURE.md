# 3. Architecture

## 3.1 全体構成

本プロジェクトは、**Virtual Reference Platform** と **PowerVS Live Validation Platform** を分離し、その上にIaC、NIM、Release Promotion、Evidence RAG、LLMを配置する。

```mermaid
flowchart TB
    subgraph REF[Virtual Reference Platform]
      HMC[Dual HMC]
      PWR[Power Systems / PowerVM]
      VIO[Dual VIOS]
      NET[SEA / Virtual Ethernet]
      FC[NPIV / vSCSI / Dual FC Fabric]
      SAN[Shared SAN]
      HMC --> PWR --> VIO
      VIO --> NET
      VIO --> FC --> SAN
    end

    subgraph LIVE[PowerVS Live Validation Platform]
      W[PowerVS Workspace]
      A1[AIX LPAR/VSI DEV01]
      A2[AIX LPAR/VSI DEV02]
      VOL[Shareable Volumes]
      NIM[NIM Server]
      HA[PowerHA]
      W --> A1
      W --> A2
      W --> VOL
      A1 --> HA
      A2 --> HA
      NIM --> A1
      NIM --> A2
    end

    D[Design as Code] --> V[Schema / Topology Validator]
    V --> R[Deterministic Rule Engine]
    R --> P[Plan Generator]
    P --> L[LLM Design / Change Reviewer]
    L --> A{Human Approval}
    A -->|Approved| X[Controlled Executor]
    X --> LIVE
    X --> NIM
    X --> C[Evidence Collectors]

    REF --> SIM[Simulated Evidence]
    LIVE --> C
    SIM --> N[Parser / Normalizer / Redactor]
    C --> N

    N --> S1[(Raw Evidence Store)]
    N --> S2[(Structured Evidence Store)]
    N --> S3[(Keyword / Vector Index)]
    N --> S4[(Topology Graph)]

    K[(Knowledge RAG)] --> Q[Hybrid Retriever]
    S2 --> Q
    S3 --> Q
    S4 --> Q
    CASE[(Case RAG)] --> Q
    Q --> E[LLM Evidence Analyst]

    E --> GATE[Promotion Review]
    GATE --> PG{Rule / Test / Evidence Gate}
    PG -->|Pass| PROMOTE[Promote Release]
    PROMOTE --> MS[mksysb / Golden Release]
    MS --> CASE
    MS --> S2
```

## 3.2 Power Platform境界

### Virtual Reference Platform
実務で想定するPower基盤全体を論理設計する。

- Dual HMC
- Power Systems / PowerVM
- LPAR Profile
- Dual VIOS
- SEA redundancy
- NPIV / vSCSI
- Dual FC Fabric
- Shared SAN
- AIX LPAR
- PowerHA

PowerVSで直接操作できないHMC / VIOS / SAN層は、設計モデル、Adapter Plan、匿名化・合成した模擬Evidenceで検証する。

### PowerVS Live Validation Platform
実機検証対象。

- PowerVS Workspace
- AIX VSI / LPAR
- CPU / Memory / Network
- PowerVS Volume / Shareable Volume
- AIX hdisk / MPIO
- PVID / VG / LV / JFS2
- Enhanced Concurrent VG
- PowerHA
- NIM
- Failover / Failback
- mksysb
- Evidence収集

PowerVS上で見えない物理層を「存在しないもの」とは扱わない。論理上位層として保持し、実測可能範囲との境界を明示する。

## 3.3 実行部品

既存のPower/AIX向けIaC資産を再利用する。

- PowerVS: Terraform Provider / Module
- AIX: Ansible Collection / shell / NIM
- HMC: HMC向けAnsible Collection等をAdapter化
- VIOS: VIOS向けAnsible Collection等をAdapter化
- PowerHA: PowerHA向けCollection / command Adapter
- Application Deployment: DevOps Deploy等の外部Release Engineを接続可能にする

本プロジェクトは既存Moduleの再実装ではなく、**統合Plan、Evidence Gate、Release Promotion、RAG、LLM、学習**を研究対象とする。

## 3.4 Release Architecture

ReleaseはAIX更新とApplication更新を一体で管理する。

```mermaid
flowchart LR
    DEF[Release Definition] --> DEV[DEV]
    DEV --> N1[NIM: TL/SP/PTF]
    DEV --> D1[Application Deploy]
    N1 --> T1[Test + Evidence]
    D1 --> T1
    T1 --> G1{Promotion Gate}
    G1 -->|Pass| QA[QA]
    G1 -->|Fail| FIX[Fix / Re-plan]
    QA --> N2[NIM: Same AIX Level]
    QA --> D2[Same Artifact]
    N2 --> T2[Test + Evidence]
    D2 --> T2
    T2 --> G2{Promotion Gate}
    G2 -->|Pass| PROD[PROD-equivalent]
    PROD --> MKS[mksysb]
    MKS --> GOLD[Golden Release]
```

Promotion Gateの確定判定はRule Engine / Test Result / Evidence Comparison / Approved Exceptionで行う。LLMはリスク要約と追加確認提案を担当する。

## 3.5 Evidence / RAG Architecture

RAGは三層構造とする。

### Knowledge RAG
- PowerVM設計原則
- HMC / VIOS
- NPIV / SEA / vSCSI
- SAN / MPIO
- AIX / LVM / JFS2
- NIM
- PowerHA
- Release運用知識

### Evidence RAG
- HMC simulated evidence
- VIOS simulated evidence
- SAN simulated evidence
- PowerVS live evidence
- NIM execution evidence
- AIX / PowerHA live evidence
- Test evidence

### Case RAG
- 正常構築
- Release成功例
- 障害
- 原因
- 是正
- 設計判断
- Regression Case
- Golden Release

検索はStructured / Keyword / Vector / Graphを組み合わせる。

## 3.6 LLM介在点

LLMは以下に限定して高い価値を出す。

1. Design Review
2. Pre-change Impact Review
3. Post-change Evidence Analysis
4. Test Failure Hypothesis / Additional Evidence Suggestion
5. Promotion Risk Summary
6. Golden / Rule / Regression候補生成

LLMは実行、確定Rule判定、昇格可否の最終決定を担当しない。

## 3.7 構築・更新シーケンス

```mermaid
sequenceDiagram
    participant U as Engineer
    participant O as Orchestrator
    participant R as Rule Engine
    participant L as LLM
    participant E as Executor
    participant N as NIM
    participant C as Evidence Pipeline
    participant G as RAG

    U->>O: Design / Release Definition
    O->>R: Schema / Topology / Rule validation
    R-->>O: Deterministic Findings
    O->>G: Similar design / release / incident retrieval
    G-->>L: Knowledge + Evidence + Cases
    L-->>U: Pre-change review / risks / required tests
    U->>O: Approval
    O->>E: IaC / Application Plan
    O->>N: AIX lifecycle Plan
    E->>C: Execution Evidence
    N->>C: TL/SP/PTF / mksysb Evidence
    C->>G: Normalize / Index
    O->>R: Test / Evidence Gate evaluation
    G->>L: Current vs Golden / Similar cases
    L-->>U: Risk summary / additional checks
    R-->>O: Promotion decision inputs
```

## 3.8 配置モデル

- Control Plane: API、Orchestrator、Rule、Promotion、LLM
- Execution Plane: Terraform / Ansible / NIM / Deploy Adapter
- Evidence Plane: Collectors、Raw Store、Structured Store、Index、Graph
- Learning Plane: Golden、Case、Rule Candidate、Regression
- Approval Plane: GitHub PRまたは専用UI
- Validation Plane: PowerVS + simulated upper Power platform
