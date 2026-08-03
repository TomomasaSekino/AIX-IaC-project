# ADR-0002: 確定判定をLLMより先に実行する

## Status
Accepted

## Context
パス数、属性不一致、必須値欠落などはコードで再現可能に判定できる。LLM単独では結果が揺れ、監査性が不足する。

## Decision
Schema、Topology、Rule、差分比較を先に実行し、LLMは結果の統合、文脈説明、類似事例、追加確認を担当する。

## Consequences
- RuleとParserのテスト資産が重要になる
- LLMは確定Findingを覆さない
- RuleとLLMが競合した場合、差異を人間へ提示する
