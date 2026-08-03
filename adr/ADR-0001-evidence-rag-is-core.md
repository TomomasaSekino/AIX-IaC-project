# ADR-0001: Evidence RAGを中核に置く

## Status
Accepted

## Context
設計書と手順書だけでは、実環境が期待状態に一致したことを保証できない。AIX/PowerHA構築では、HMC、VIOS、SAN、AIX、PowerHAの実測証跡を横断して確認する必要がある。

## Decision
Evidence RAGを補助検索ではなく、設計比較、構築検証、障害解析、学習の中心基盤とする。

## Consequences
- Evidenceの収集・正規化・出典管理が最優先になる
- 生ログをそのままEmbeddingするだけでは不十分
- Structured、Keyword、Vector、Graphを併用する
- 回答はEvidence IDを必須とする
