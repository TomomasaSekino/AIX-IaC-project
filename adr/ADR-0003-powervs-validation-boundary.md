# ADR-0003: PowerVS実機検証とVirtual Reference Platformを分離する

## Status
Accepted

## Context

PowerVSはAIX / PowerVM基盤を利用できる一方、利用者がHMC、VIOS、SEA、物理FC Fabric、SAN基盤を直接管理する構成ではない。

AIX / PowerHAのみを研究対象にすると、Power基盤全体の設計能力と障害ドメインが失われ、研究対象が単なるOS自動化へ縮退する。

## Decision

設計対象はPower基盤全体とするが、検証方法を二層へ分離する。

### Virtual Reference Platform
- Dual HMC
- Power Systems / PowerVM
- Dual VIOS
- SEA redundancy
- NPIV / vSCSI
- Dual FC Fabric
- Shared SAN

当該層は論理設計、Plan、匿名化・合成したsimulated evidenceで検証する。

### PowerVS Live Validation Platform
- AIX LPAR/VSI
- Network / Volume
- MPIO
- LVM / JFS2
- Enhanced Concurrent VG
- NIM
- PowerHA
- Failover / Failback

当該層はlive evidenceで検証する。

## Consequences

- Power基盤全体の設計意図を維持できる
- PowerVSで実測できない項目を実測済みと誤認しない
- Evidenceにorigin / validation statusが必要になる
- 将来オンプレPower環境へAdapterを接続した際にsimulated evidenceをlive evidenceへ置き換えられる
