// === Connect Wallet ===
async function connectWallet() {
  if (window.ethereum) {
    try {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      const account = accounts[0];
      document.getElementById("walletAddress").innerText =
        "Connected: " + account.slice(0,6) + "..." + account.slice(-4);
      console.log("✅ Connected:", account);
    } catch (err) {
      console.error("User rejected connection", err);
    }
  } else {
    alert("Please install MetaMask or Rabby Wallet!");
  }
}

document.getElementById("connectButton").addEventListener("click", connectWallet);

// === Buy VoltPay ===
document.getElementById("buyButton").addEventListener("click", () => {
  const url = "https://pancakeswap.finance/swap?outputCurrency=0x73Bb9eC961AfC372957D4e3Fcaace918f95BBC73&chain=bsc";
  window.open(url, "_blank");
});
