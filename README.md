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

The Solidity source is frozen and corresponds to the contract deployed and verified on BNB Smart Chain Mainnet. Token allocation and presale updates described below do not change the deployed smart contract or the fixed total supply.

---

## 📊 Tokenomics — Version 3.0

VoltPay has a fixed, non-inflationary total supply of:

**200,000,000 VLT**

| Allocation | VLT | Share |
| --- | ---: | ---: |
| Strategic Reserve | 100,000,000 | 50% |
| Founder Allocation | 20,000,000 | 10% |
| Presale | 30,000,000 | 15% |
| Liquidity Reserve | 20,000,000 | 10% |
| Team | 10,000,000 | 5% |
| Marketing & Community | 8,000,000 | 4% |
| Exchange Listings & Market Expansion | 7,000,000 | 3.5% |
| Development & Operations | 5,000,000 | 2.5% |
| **Total** | **200,000,000** | **100%** |

Strategic, founder, team and other designated allocations may be subject to on-chain locking or vesting schedules.

Detailed on-chain lock and vesting records are maintained separately through VoltPay's transparency resources.

### Presale Parameters

- **Soft Cap:** `$50,000`
- **Hard Cap:** `$200,000`
- **Maximum Presale Allocation:** `30,000,000 VLT`
- **Presale Price:** `$0.0068` per VLT
- **Planned Listing Price:** `$0.0076` per VLT
- **Minimum Contribution:** `$25 equivalent`
- **Maximum Contribution:** `$5,000 equivalent per wallet`
- **Presale Duration:** `14 days`
- **Liquidity Allocation:** `75%`
- **LP Lock:** `365 days`
- **Buyer Vesting:** `60% at TGE, 20% after 15 days, 20% after 30 days`
- **Unsold Tokens:** Returned to the project, segregated, and reserved for transparent future ecosystem use; they will not be automatically burned.

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

An independent third-party smart contract audit is currently being arranged as part of VoltPay's pre-launch security process. The final audit report will be published through the project's official transparency resources once completed.

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

- **[Current Whitepaper — Version 3.0](docs/current/VoltPay_VLT_Whitepaper_Version_3.0_Presale_Edition_September_2026.pdf)**
- **[Current Tokenomics — Version 3.0](docs/current/VoltPay_VLT_Tokenomics_Version_3.0_Presale_Edition_September_2026.pdf)**
- **[Historical Whitepaper (superseded)](docs/archive/VoltPay_VLT_Whitepaper_Final_Mainnet_Edition_August_2026.pdf)**
- **[Historical Tokenomics (superseded)](docs/archive/VoltPay_VLT_Tokenomics_Strict_Mainnet_Edition_August_2026.pdf)**

Version 3.0 supersedes previous VoltPay allocation and presale-planning documents.

Historical files are retained only for version transparency and must not be used as the current Whitepaper or allocation model.

---

## 🔎 Transparency

VoltPay publishes verifiable on-chain references for token locks, vesting schedules, liquidity, presale-related allocations, and other relevant project reserves through its transparency resources.

Detailed lock and vesting records are maintained separately from the main project documentation to keep verification links current and easy to review.

Official transparency page:

**https://voltpay.org/transparency**

Additional on-chain references, including liquidity and presale records, will be added as they become available.

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
