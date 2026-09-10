<p align="center">
  <img src="./VoltPay-Logo.png" alt="VoltPay Logo" width="180">
</p>

<h1 align="center">VoltPay (VLT) — Official Smart Contract Repository ⚡</h1>

<p align="center">
  <strong>BNB Smart Chain • Web3 Payments • Non-Custodial Wallet • VoltAI</strong>
</p>

<p align="center">
  <a href="https://voltpay.org">Website</a> •
  <a href="https://bscscan.com/address/0xE90714e6e4becEc65F33D3099F95B42B6e3168aE#code">BscScan</a> •
  <a href="https://voltpay.org/transparency">Transparency</a> •
  <a href="./docs/current/">Documentation</a>
</p>

---

VoltPay is a Web3 payments ecosystem being developed to make digital-asset payments simpler by combining blockchain infrastructure, a non-custodial wallet, and AI-assisted user tools.

This repository contains the **official verified VoltPay V2 Mainnet smart contract**, current official project documentation, and security references for the VoltPay ecosystem.

---

## 📄 Verified Smart Contract

| Parameter | Official Value |
| --- | --- |
| **Network** | BNB Smart Chain (BSC Mainnet) |
| **Chain ID** | `56` |
| **VLT Contract** | `0xE90714e6e4becEc65F33D3099F95B42B6e3168aE` |
| **VLT / WBNB Pair** | `0x6cFF8650a2e8Affd64a48eaf227A0C74cE767892` |
| **PancakeSwap V2 Router** | `0x10ED43C718714eb63d5aA57B78B54704E256024E` |
| **Compiler** | Solidity `0.8.35` |
| **Optimizer** | Enabled — `200 runs` |
| **EVM Version** | `paris` |
| **BscScan Verification** | **Exact Match** |
| **Trading Status** | Disabled until official launch |
| **Liquidity Status** | Not yet added |

### 🔎 BscScan

[**View the verified VLT smart contract on BscScan →**](https://bscscan.com/address/0xE90714e6e4becEc65F33D3099F95B42B6e3168aE#code)

---

## 🔐 Frozen Contract Source

Official Mainnet source:

`VoltPayV2_FINAL_0_8_35.sol`

**SHA-256**

`9d708e7e874bdf72533d1f59d976049dfeeff9f3555aeccfd4c2bfdc94cbcdae`

The Solidity source is frozen and corresponds to the contract deployed and verified on BNB Smart Chain Mainnet.

Documentation, token allocation, presale parameters, locks, vesting schedules, and ecosystem updates do not modify the deployed smart contract or its fixed total supply.

---

## 📊 Tokenomics — Version 3.0 Rev2

VoltPay has a fixed, non-inflationary total supply of:

# **200,000,000 VLT**

| Allocation | VLT | Share |
| --- | ---: | ---: |
| Strategic Reserve | 100,000,000 | 50% |
| Founder Allocation | 20,000,000 | 10% |
| Presale | 30,000,000 | 15% |
| Liquidity Reserve | 20,000,000 | 10% |
| Team | 10,000,000 | 5% |
| Marketing & Community | 7,000,000 | 3.5% |
| Exchange Listings & Market Expansion | 6,000,000 | 3% |
| Development & Operations | 5,000,000 | 2.5% |
| Strategic Investor | 2,000,000 | 1% |
| **Total** | **200,000,000** | **100%** |

The **Strategic Investor allocation of 2,000,000 VLT (1%)** is included in the current Rev2 allocation model.

The total supply remains unchanged at **200,000,000 VLT**.

Strategic, founder, team, investor, and other designated allocations may be subject to on-chain locking or vesting schedules.

Detailed on-chain lock and vesting information is maintained through VoltPay's transparency resources.

---

## 🚀 Presale Parameters

| Parameter | Planned Configuration |
| --- | ---: |
| **Soft Cap** | `$50,000` |
| **Hard Cap** | `$200,000` |
| **Maximum Presale Allocation** | `30,000,000 VLT` |
| **Presale Price** | `$0.0068 / VLT` |
| **Planned Listing Price** | `$0.0076 / VLT` |
| **Minimum Contribution** | `$25 equivalent` |
| **Maximum Contribution** | `$5,000 equivalent per wallet` |
| **Presale Duration** | `14 days` |
| **Liquidity Allocation** | `75%` |
| **LP Lock** | `365 days` |
| **Buyer Vesting** | `60% TGE / 20% after 15 days / 20% after 30 days` |

**Unsold Tokens:** Returned to the project, segregated, and reserved for transparent future ecosystem use. They will not be automatically burned.

Final presale parameters remain subject to the configuration accepted and published on the official launchpad before contributions open.

---

## 💰 Fee Model

VoltPay uses a transaction-based fee structure:

- **Buy Fee:** `2%`
- **Sell Fee:** `4%`

Collected fees accumulate in the smart contract and are processed through the `processFees()` mechanism.

Processed fees are allocated:

- **50% → Liquidity**
- **50% → Treasury**

This design separates fee accumulation from normal user transfers and supports controlled liquidity and treasury processing.

---

## 🛡️ Security Validation

VoltPay V2 completed extensive internal testing and automated security validation before Mainnet deployment:

- ✅ `93/93` local Hardhat tests passed
- ✅ BSC Mainnet fork test passed
- ✅ Total automated result: `94/94 PASS`
- ✅ Mythril security analysis completed
- ✅ SolidityScan Security Score: `93.18`
- ✅ Critical findings: `0`
- ✅ High findings: `0`
- ✅ Medium findings: `0`
- ✅ Live BSC Testnet validation completed
- ✅ Buy fee validation: PASS
- ✅ Sell fee validation: PASS
- ✅ Anti-whale validation: PASS
- ✅ Fee processing validation: PASS
- ✅ Treasury pull-payment validation: PASS
- ✅ Post-renounce fee processing validation: PASS

These results are internal and automated validation references and are not a substitute for an independent third-party audit.

An independent third-party smart contract audit is being arranged as part of VoltPay's pre-launch security process. The final report will be published through the project's official transparency resources once completed.

---

## 🔒 Contract Safety Features

VoltPay V2 includes:

- Fixed non-inflationary supply
- No minting function
- One-way trading activation
- Fees can only be reduced
- Permanent fee locking
- Permanent configuration locking
- Permanent swap-settings locking
- Removable anti-whale limits
- Manual fee processing
- Pull-payment treasury mechanism
- Controlled ownership renouncement process

---

## 🌐 VoltPay Ecosystem

VoltPay is being developed as more than a standalone token.

The ecosystem includes:

- ⚡ **VLT** — the native VoltPay utility and payment token
- 👛 **VoltPay Wallet** — non-custodial digital-asset wallet
- 🤖 **VoltAI** — AI-assisted user experience
- ✈️ **Telegram Ecosystem** — wallet and community integrations
- 💳 **Payment Infrastructure** — future merchant and payment integrations

### Live / Deployed

- VLT Mainnet smart contract deployed and verified on BNB Smart Chain
- Official VoltPay website
- Public VoltPay community and social channels
- Mainnet fork testing completed
- BSC Testnet validation completed
- Automated security validation completed

### Pre-Launch / Continuing Development

- VoltPay Wallet development and refinement
- Telegram wallet integration
- VoltAI development and integration
- Presale infrastructure
- Launch documentation
- Security and production-readiness work

### Planned / Partner-Dependent

- Fiat on-ramp integrations
- Mobile wallet distribution
- Chrome wallet extension
- Merchant payment integrations
- Sponsored VLT transfers
- Ecosystem integrations
- Exchange partnerships

Future availability may depend on technical testing, security reviews, regulatory requirements, funding, and third-party approvals.

---

## 📚 Official Documents

### ✅ Current Official Documentation

- [**VoltPay Whitepaper — Version 3.0 Rev2 — Presale Edition — September 2026**](./docs/current/VoltPay_VLT_Whitepaper_Version_3.0_Presale_Edition_September_2026_Rev2.pdf)
- [**VoltPay Tokenomics — Version 3.0 Rev2 — Presale Edition — September 2026**](./docs/current/VoltPay_VLT_Tokenomics_Version_3.0_Presale_Edition_September_2026_Rev2.pdf)
- [**Current Documentation Directory →**](./docs/current/)

**Version 3.0 Rev2 is the current official VoltPay documentation.**

It supersedes earlier Version 3.0 revisions and previous allocation and presale-planning documents.

### 📦 Historical Documentation

[**View archived VoltPay documents →**](./docs/archive/)

Historical documents are retained for transparency and version history and must not be treated as current project documentation.

---

## 🔎 Transparency

VoltPay publishes verifiable on-chain references for token locks, vesting schedules, liquidity, presale-related allocations, and other relevant project reserves.

Detailed lock and vesting records are maintained separately from the primary project documentation so verification links can remain current.

### Official Transparency Page

[**voltpay.org/transparency →**](https://voltpay.org/transparency)

Additional on-chain references, including liquidity and presale records, will be added as they become available.

---

## 🔗 Official VoltPay Links

| Channel | Official Link |
| --- | --- |
| 🌐 **Website** | https://voltpay.org |
| ✉️ **Email** | info@voltpay.org |
| 💻 **GitHub** | https://github.com/volt-pay |
| 𝕏 **X / Twitter** | https://x.com/VoltPayInfo |
| ✈️ **Telegram** | https://t.me/VoltPayorg |
| ▶️ **YouTube** | https://www.youtube.com/channel/UCUagEhm_XXi0AoGi0AOYseQ |
| 🎵 **TikTok** | https://www.tiktok.com/@voltpay.org |
| 📸 **Instagram** | https://www.instagram.com/voltpay.info/ |

---

## ⚠️ Disclaimer

Cryptocurrency markets involve substantial risk.

VoltPay does not guarantee token price appreciation, investment returns, market liquidity, presale completion, product delivery dates, partnership approvals, or future exchange listings.

Users should independently review the smart contract, current documentation, presale terms, and available on-chain data before interacting with VLT.

Nothing in this repository constitutes financial, legal, tax, or investment advice.

---

<p align="center">
  <strong>© 2026 VOLT LABS LLC. All Rights Reserved.</strong>
</p>

<p align="center">
  Powered by BNB Smart Chain • <a href="https://voltpay.org">voltpay.org</a>
</p>
