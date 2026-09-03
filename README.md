<p align="center">
  <img src="VoltPay-Logo.png" alt="VoltPay VLT Logo" width="190">
</p>

# VoltPay (VLT) — Official Smart Contract Repository ⚡

VoltPay is a Web3 payments ecosystem being developed to make digital-asset payments simpler by combining blockchain infrastructure, a non-custodial wallet, and AI-assisted user tools.

This repository contains the **official verified VoltPay V2 Mainnet smart contract**, current official project documentation, and security references for the VoltPay ecosystem.

---

## 📄 Verified Smart Contract

- **Network:** BNB Smart Chain (BSC Mainnet)
- **Chain ID:** `56`
- **Contract Address:** `0xE90714e6e4becEc65F33D3099F95B42B6e3168aE`
- **VLT / WBNB Pair:** `0x6cFF8650a2e8Affd64a48eaf227A0C74cE767892`
- **PancakeSwap V2 Router:** `0x10ED43C718714eb63d5aA57B78B54704E256024E`
- **Compiler:** Solidity `0.8.35`
- **Optimizer:** Enabled — `200 runs`
- **EVM Version:** `paris`
- **Verification:** BscScan — **Exact Match**
- **Trading Status:** Disabled until the official launch
- **Liquidity Status:** Not yet added

🔎 **BscScan:**  
https://bscscan.com/address/0xE90714e6e4becEc65F33D3099F95B42B6e3168aE#code

---

## 🔐 Frozen Contract Source

Official Mainnet source:

`VoltPayV2_FINAL_0_8_35.sol`

**SHA-256**

`9d708e7e874bdf72533d1f59d976049dfeeff9f3555aeccfd4c2bfdc94cbcdae`

The Solidity source is frozen and corresponds to the contract deployed and verified on BNB Smart Chain Mainnet. Token allocation updates described below do not change the deployed smart contract or the fixed total supply.

---

## 📊 Tokenomics — Version 2.0

VoltPay has a fixed, non-inflationary total supply of:

**200,000,000 VLT**

| Allocation | VLT | Share | Lock / Vesting Status |
| --- | ---: | ---: | --- |
| Strategic Reserve | 100,000,000 | 50% | 12-month lock planned; on-chain proof pending |
| Founder Allocation | 20,000,000 | 10% | 10,000,000 planned for a 12-month lock; 10,000,000 unlocked |
| Presale | 30,000,000 | 15% | Reserved for the planned public presale |
| Liquidity | 20,000,000 | 10% | Reserved for initial and future liquidity |
| Team | 10,000,000 | 5% | 3-month cliff followed by 12-month linear vesting; deployment pending |
| Marketing & Community | 8,000,000 | 4% | Growth, community, campaigns, and ecosystem adoption |
| Exchange Listings & Market Expansion | 7,000,000 | 3.5% | Exchange integrations, listings, and market expansion |
| Development & Operations | 5,000,000 | 2.5% | Product development, infrastructure, security, and operations |
| **Total** | **200,000,000** | **100%** | **Fixed supply** |

Lock and vesting descriptions are commitments planned for implementation. They must not be interpreted as completed until the corresponding on-chain transactions and verifiable addresses are published.

### Planned Presale Parameters

- **Soft Cap:** `$75,000`
- **Hard Cap:** `$150,000–$200,000`
- **Presale Allocation:** `30,000,000 VLT`
- **Presale Price:** `$0.0068` per VLT
- **Planned Listing Price:** `$0.0076` per VLT
- **Target Share of Presale Proceeds for Liquidity:** `65%`
- **Planned LP Lock:** `12 months`

Presale parameters remain subject to final platform configuration, security review, and publication of the official presale terms before contributions open.

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

These results are internal and automated validation references and are not a substitute for an independent third-party audit. An independent audit is planned before the public presale or official launch, subject to funding and provider availability.

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

## 🌐 VoltPay Ecosystem & Development Status

### Live / Deployed

- VLT Mainnet smart contract deployed and verified on BNB Smart Chain
- Official website and public project channels
- Mainnet fork, testnet, and automated security validation completed

### In Development

- Non-custodial VoltPay Wallet
- Telegram wallet integration
- VoltAI assistant
- Presale infrastructure and launch documentation

### Planned / Partner-Dependent

- Fiat on-ramp integrations
- Mobile wallet applications
- Chrome wallet extension
- Merchant payment integrations
- Sponsored VLT transfers inside VoltPay Wallet
- Additional ecosystem and exchange partnerships

Items described as planned or in development are not yet guaranteed production features. Availability may depend on technical testing, security reviews, regulatory requirements, funding, and third-party approvals.

---

## 📚 Official Documents

- **[Current Whitepaper (Version 2.0)](docs/current/VoltPay_VLT_Whitepaper_Version_2.0_Final_Mainnet_Edition_August_2026.pdf)**
- **[Current Tokenomics (Version 2.0)](docs/current/VoltPay_VLT_Tokenomics_Version_2.0_Final_Mainnet_Edition_August_2026.pdf)**
- **[Historical Whitepaper (superseded)](docs/archive/VoltPay_VLT_Whitepaper_Final_Mainnet_Edition_August_2026.pdf)**
- **[Historical Tokenomics (superseded)](docs/archive/VoltPay_VLT_Tokenomics_Strict_Mainnet_Edition_August_2026.pdf)**

Historical files are retained only for version transparency and must not be used as the current Whitepaper or allocation model.

---

## 🔎 Transparency Roadmap

VoltPay intends to publish verifiable on-chain proof for:

- 🔐 Strategic Reserve lock
- 👤 Locked portion of the Founder Allocation
- 👥 Team vesting
- 💧 Liquidity and LP lock
- 🥞 Mainnet liquidity pool
- 🚀 Presale allocation and distribution
- 🏦 Relevant treasury, marketing, development, and ecosystem wallets

These references will be added to this repository as each action is completed. Until a transaction or contract address is published, the corresponding item should be treated as pending.

---

## 🔗 Official Links

- 🌐 **Website:** https://voltpay.org
- ✉️ **Email:** info@voltpay.org
- 💻 **GitHub:** https://github.com/volt-pay
- 𝕏 **X / Twitter:** https://x.com/VoltPayInfo
- ✈️ **Telegram:** https://t.me/VoltPayorg
- ▶️ **YouTube:** https://www.youtube.com/channel/UCUagEhm_XXi0AoGi0AOYseQ
- 🎵 **TikTok:** https://www.tiktok.com/@voltpay.org
- 📸 **Instagram:** https://www.instagram.com/voltpay.info/

---

## ⚠️ Disclaimer

Cryptocurrency markets involve substantial risk.

VoltPay does not guarantee token price appreciation, investment returns, market liquidity, presale completion, product delivery dates, partnership approvals, or future exchange listings.

Users should independently review the smart contract, current documentation, presale terms, and on-chain data before interacting with VLT. Nothing in this repository constitutes financial, legal, tax, or investment advice.

---

<p align="center">
  <strong>© 2026 VOLT LABS LLC. All Rights Reserved.</strong><br>
  Powered by BNB Smart Chain | voltpay.org
</p>
