// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/// @title Uniswap V2 compatible factory interface
/// @author VoltPay Team
/// @dev Minimal factory interface required for pair creation.
interface IUniswapV2Factory {
    /// @notice Creates a liquidity pair for two token addresses.
    /// @dev Minimal factory operation used during VoltPay deployment.
    /// @param tokenA First token address.
    /// @param tokenB Second token address.
    /// @return pair Address of the created liquidity pair.
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/// @title Uniswap V2 compatible router interface
/// @author VoltPay Team
/// @dev Minimal router interface required for swaps and liquidity operations.
interface IUniswapV2Router02 {
    /// @notice Returns the router factory address.
    /// @dev Used to resolve the factory associated with the configured router.
    /// @return Factory contract address.
    function factory() external pure returns (address);

    /// @notice Returns the wrapped native-token address used by the router.
    /// @dev Used to resolve the wrapped BNB token paired with VLT.
    /// @return Wrapped native-token contract address.
    function WETH() external pure returns (address);

    /// @notice Adds token/native liquidity through the router.
    /// @dev Minimal router operation used by VoltPay fee processing.
    /// @param token Token address.
    /// @param amountTokenDesired Desired token amount.
    /// @param amountTokenMin Minimum token amount accepted.
    /// @param amountETHMin Minimum native amount accepted.
    /// @param to Recipient of minted LP tokens.
    /// @param deadline Router execution deadline.
    /// @return amountToken Actual token amount used.
    /// @return amountETH Actual native amount used.
    /// @return liquidity Amount of LP tokens minted.
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    /// @notice Swaps an exact token amount for native currency while supporting fee-on-transfer tokens.
    /// @dev Minimal router swap operation used by VoltPay fee processing.
    /// @param amountIn Exact input-token amount.
    /// @param amountOutMin Minimum native output accepted.
    /// @param path Ordered swap path.
    /// @param to Native-currency recipient.
    /// @param deadline Router execution deadline.
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

/// @title VoltPay V2 Clean Launch Contract
/// @author VoltPay Team
/// @notice Fixed-supply BEP-20 token with buy/sell fees, auto-liquidity,
/// treasury distribution, launch limits, and irreversible configuration locks.
/// @dev Uses BNB Smart Chain compatible Uniswap V2 infrastructure, pull-based
/// treasury accounting, bounded fee processing, and irreversible safety locks.
contract VoltPayV2 is ERC20, Ownable2Step, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice Fixed total VLT supply minted at deployment.
    uint256 public constant TOTAL_SUPPLY = 200_000_000 * 1e18;

    /// @notice Absolute upper bound permitted for a fee-processing transaction.
    uint256 public constant MAX_SWAP_CAP = TOTAL_SUPPLY / 1000; // 200,000 VLT

    /// @notice Current buy fee in basis points.
    uint256 public buyFee = 200;  // 2%

    /// @notice Current sell fee in basis points.
    uint256 public sellFee = 400; // 4%

    /// @notice Percentage of collected fees allocated to liquidity accounting.
    uint256 public constant LIQUIDITY_SHARE = 50;

    /// @notice Maximum future deadline accepted by fee processing.
    uint256 public constant MAX_PROCESS_DEADLINE = 15 minutes;

    /// @notice Maximum VLT amount permitted per limited transaction.
    uint256 public maxTx = 30_000 * 1e18;

    /// @notice Maximum VLT balance permitted for a limited wallet.
    uint256 public maxWallet = 30_000 * 1e18;

    /// @notice Minimum accumulated VLT normally required before fee processing.
    uint256 public swapThreshold = 12_000 * 1e18;

    /// @notice Maximum VLT amount that may be processed in one operation.
    uint256 public maxSwapAmount = 30_000 * 1e18;

    /// @notice BNB accrued for the immutable treasury and not yet withdrawn.
    uint256 public pendingTreasuryBNB;

    /// @notice Immutable PancakeSwap-compatible router used by the token.
    IUniswapV2Router02 public immutable router;

    /// @notice Immutable primary VLT/WBNB liquidity pair.
    address public immutable pair;

    /// @notice Runtime code hash of the primary PancakeSwap-compatible pair implementation.
    /// @dev Used to recognize additional pairs of the same implementation without external calls.
    bytes32 public immutable primaryPairCodeHash;

    /// @notice Immutable treasury recipient.
    address public immutable treasury;

    /// @notice Irrecoverable address receiving liquidity tokens.
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    /// @notice Whether public trading has been permanently enabled.
    bool public tradingEnabled;

    /// @notice Whether transaction and wallet limits have been permanently removed.
    bool public limitsRemoved;

    /// @notice Whether fee configuration has been permanently locked.
    bool public feesLocked;

    /// @notice Whether pair and exemption configuration has been permanently finalized.
    bool public configFinalized;

    /// @notice Whether swap settings have been permanently locked.
    bool public swapSettingsLocked;

    bool private _inSwap;

    /// @notice Returns whether an address is exempt from token fees.
    mapping(address account => bool exempt) public isFeeExempt;

    /// @notice Returns whether an address is exempt from transaction and wallet limits.
    mapping(address account => bool exempt) public isLimitExempt;

    /// @notice Returns whether an address is registered as a trading pair.
    mapping(address account => bool pairStatus) public isPair;

    /// @notice Restricts fee processing operations to the owner or immutable treasury.
    /// @dev The treasury remains authorized even after ownership is renounced.
    modifier onlyFeeProcessor() {
        require(msg.sender == owner() || msg.sender == treasury, "Not fee processor");
        _;
    }

    /// @notice Prevents nested execution of fee-processing operations.
    /// @dev Uses an internal swap-state guard in addition to ReentrancyGuard.
    modifier lockSwap() {
        require(!_inSwap, "Swap already running");
        _inSwap = true;
        _;
        _inSwap = false;
    }

    event TradingEnabled();
    event LimitsRemoved();
    event LimitsUpdated(uint256 indexed maxTx, uint256 maxWallet);
    event FeesLocked();
    event ConfigFinalized();
    event SwapSettingsLocked();
    event FeesUpdated(uint256 indexed buyFee, uint256 sellFee);
    event SwapSettingsUpdated(uint256 indexed threshold, uint256 maxAmount);
    event PairUpdated(address indexed pairAddress, bool indexed status);
    event ExemptionsUpdated(address indexed account, bool feeExempt, bool limitExempt);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity,
        uint256 ethIntoLiquidity,
        uint256 liquidityMinted,
        address indexed lpRecipient
    );
    event TreasuryTransferFailed(uint256 amount);
    event TreasuryPaid(uint256 amount);
    event TreasuryAccrued(uint256 indexed amount, uint256 totalPending);
    event BNBRescued(address indexed recipient, uint256 amount);
    event TokensRescued(address indexed token, address indexed recipient, uint256 amount);

    /// @notice Deploys VoltPay and creates its primary VLT/WBNB pair.
    /// @dev Validates router, factory, wrapped-native token, pair, and treasury addresses.
    /// @param _router PancakeSwap-compatible router address.
    /// @param _treasury Immutable treasury recipient address.
    constructor(address _router, address _treasury)
        ERC20("VoltPay", "VLT")
        Ownable(msg.sender)
    {
        require(_router != address(0), "Router zero");
        require(_router.code.length > 0, "Router not contract");
        require(_treasury != address(0), "Treasury zero");

        router = IUniswapV2Router02(_router);
        treasury = _treasury;

        address factoryAddress = router.factory();
        address wrappedBNB = router.WETH();

        require(factoryAddress != address(0), "Factory zero");
        require(factoryAddress.code.length > 0, "Factory not contract");
        require(wrappedBNB != address(0), "WBNB zero");
        require(wrappedBNB.code.length > 0, "WBNB not contract");

        address createdPair = IUniswapV2Factory(factoryAddress).createPair(
            address(this),
            wrappedBNB
        );

        require(createdPair != address(0), "Pair zero");
        require(createdPair.code.length > 0, "Pair not contract");

        bytes32 createdPairCodeHash = createdPair.codehash;
        require(createdPairCodeHash != bytes32(0), "Pair codehash zero");

        pair = createdPair;
        primaryPairCodeHash = createdPairCodeHash;
        isPair[createdPair] = true;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[_treasury] = true;

        isLimitExempt[msg.sender] = true;
        isLimitExempt[address(this)] = true;
        isLimitExempt[_treasury] = true;
        isLimitExempt[createdPair] = true;

        _mint(msg.sender, TOTAL_SUPPLY);
    }

    // =========================
    // OWNER CONTROLS & SAFETY
    // =========================

    /// @notice Permanently enables public token trading.
    /// @dev Can be executed only once by the current owner.
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "enabled");
        tradingEnabled = true;
        emit TradingEnabled();
    }

    /// @notice Permanently removes transaction and wallet limits.
    /// @dev Once removed, limits cannot be restored.
    function removeLimits() external onlyOwner {
        require(!limitsRemoved, "removed");
        limitsRemoved = true;
        emit LimitsRemoved();
    }

    /// @notice Increases the active transaction and wallet limits.
    /// @dev Limits may only move upward before permanent removal.
    /// @param newMaxTx New maximum transaction amount.
    /// @param newMaxWallet New maximum wallet balance.
    function increaseLimits(uint256 newMaxTx, uint256 newMaxWallet) external onlyOwner {
        require(!limitsRemoved, "Limits removed");
        require(newMaxTx >= maxTx, "Cannot reduce maxTx");
        require(newMaxWallet >= maxWallet, "Cannot reduce maxWallet");
        require(newMaxWallet >= newMaxTx, "Wallet below tx");

        maxTx = newMaxTx;
        maxWallet = newMaxWallet;

        emit LimitsUpdated(newMaxTx, newMaxWallet);
    }

    /// @notice Adds or removes a secondary trading-pair designation.
    /// @dev The immutable primary pair cannot be removed and trading pairs cannot be fee exempt.
    /// @param pairAddress Address whose trading-pair status is being configured.
    /// @param status True to register the address as a pair, false to remove it.
    function setPair(address pairAddress, bool status) external onlyOwner {
        require(!configFinalized, "Config finalized");
        require(pairAddress != address(0), "Pair zero");
        require(pairAddress != pair || status, "Cannot remove primary pair");
        // A trading pair must never bypass buy/sell fees.
        /// @dev Enforces that a registered trading pair can never bypass buy/sell fees.
        if (status) {
            require(!isFeeExempt[pairAddress], "Fee-exempt pair forbidden");
        }

        isPair[pairAddress] = status;
        isLimitExempt[pairAddress] = status;

        emit PairUpdated(pairAddress, status);
    }

    /// @notice Configures fee and limit exemptions for an address.
    /// @dev Pair addresses cannot receive exemptions and configuration becomes immutable after finalization.
    /// @param account Address whose exemptions are being configured.
    /// @param feeExempt Whether the address is exempt from buy/sell fees.
    /// @param limitExempt Whether the address is exempt from transaction and wallet limits.
    function setExemptions(
        address account,
        bool feeExempt,
        bool limitExempt
    ) external onlyOwner {
        require(!configFinalized, "Config finalized");
        require(account != address(0), "Account zero");
        require(!_isAmmPair(account), "Pair exemptions forbidden");

        isFeeExempt[account] = feeExempt;
        isLimitExempt[account] = limitExempt;

        emit ExemptionsUpdated(account, feeExempt, limitExempt);
    }

    /// @notice Permanently freezes pair and exemption configuration.
    /// @dev This operation is irreversible.
    function finalizeConfig() external onlyOwner {
        require(!configFinalized, "Already finalized");
        configFinalized = true;
        emit ConfigFinalized();
    }

    /// @notice Reduces the active buy and sell fees.
    /// @dev Neither fee may be increased and fee changes stop permanently after locking.
    /// @param newBuyFee New buy fee in basis points.
    /// @param newSellFee New sell fee in basis points.
    function reduceFees(uint256 newBuyFee, uint256 newSellFee) external onlyOwner {
        require(!feesLocked, "locked");
        require(newBuyFee <= buyFee && newSellFee <= sellFee, "only reduce");

        buyFee = newBuyFee;
        sellFee = newSellFee;

        emit FeesUpdated(newBuyFee, newSellFee);
    }

    /// @notice Permanently locks the current buy and sell fees.
    /// @dev Once locked, fees can no longer be changed.
    function lockFees() external onlyOwner {
        require(!feesLocked, "locked");
        feesLocked = true;
        emit FeesLocked();
    }

    /// @notice Permanently locks fee-processing threshold and maximum amount settings.
    /// @dev This operation is irreversible.
    function lockSwapSettings() external onlyOwner {
        require(!swapSettingsLocked, "Already locked");
        swapSettingsLocked = true;
        emit SwapSettingsLocked();
    }

    /// @notice Updates fee-processing threshold and per-operation maximum.
    /// @dev Values remain bounded by the immutable maximum swap cap.
    /// @param threshold Minimum accumulated VLT normally required for processing.
    /// @param maxAmount Maximum VLT permitted in one processing operation.
    function setSwapSettings(uint256 threshold, uint256 maxAmount) external onlyOwner {
        require(!swapSettingsLocked, "Swap settings locked");
        require(threshold > 0, "Threshold low");
        require(maxAmount >= threshold, "Max less than threshold");
        require(maxAmount <= MAX_SWAP_CAP, "Max amount too high");

        swapThreshold = threshold;
        maxSwapAmount = maxAmount;

        emit SwapSettingsUpdated(threshold, maxAmount);
    }

    /// @inheritdoc Ownable
    /// @notice Permanently renounces contract ownership after all safety prerequisites are locked.
    /// @dev Requires trading, fees, limits, configuration, and swap settings to already be finalized.
    function renounceOwnership() public override onlyOwner {
        require(tradingEnabled, "Trading must be enabled first");
        require(feesLocked, "Fees must be locked first");
        require(limitsRemoved, "Limits must be removed first");
        require(configFinalized, "Config must be finalized");
        require(swapSettingsLocked, "Swap settings must be locked");

        super.renounceOwnership();
    }

    // =========================
    // RESCUE & TREASURY
    // =========================

    /// @notice Rescues only surplus BNB that is not reserved for the treasury.
    /// @dev The pending treasury ledger is excluded from the amount available to the owner.
    function rescueBNB() external nonReentrant onlyOwner {
        uint256 contractBalance = address(this).balance;
        uint256 reservedForTreasury = pendingTreasuryBNB;

        require(contractBalance > reservedForTreasury, "No rescue BNB available");

        uint256 rescueAmount = contractBalance - reservedForTreasury;
        address recipient = owner();

        Address.sendValue(payable(recipient), rescueAmount);

        emit BNBRescued(recipient, rescueAmount);
    }

    /// @notice Rescues the full balance of an unrelated ERC-20 token sent to this contract.
    /// @dev Native VLT cannot be rescued and SafeERC20 is used for the external token transfer.
    /// @param tokenAddress Address of the external ERC-20 token to rescue.
    function rescueTokens(address tokenAddress) external nonReentrant onlyOwner {
        require(tokenAddress != address(0), "Token zero");
        require(tokenAddress != address(this), "Cannot rescue native VLT tokens");
        require(tokenAddress.code.length > 0, "Token not contract");

        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        require(tokenBalance > 0, "No tokens");

        address recipient = owner();
        IERC20(tokenAddress).safeTransfer(recipient, tokenBalance);

        emit TokensRescued(tokenAddress, recipient, tokenBalance);
    }

    /// @notice Pays all accrued BNB to the immutable treasury.
    /// @dev Uses strict checks-effects-interactions. If treasury rejects BNB,
    /// the transaction reverts and pendingTreasuryBNB is restored automatically.
    function retryTreasuryPayment()
        external
        nonReentrant
        onlyFeeProcessor
    {
        uint256 amount = pendingTreasuryBNB;
        require(amount > 0, "Nothing pending");

        pendingTreasuryBNB = 0;

        Address.sendValue(payable(treasury), amount);

        emit TreasuryPaid(amount);
    }

    // =========================
    // TRANSFER LOGIC
    // =========================

    /// @notice Returns whether an address is a registered or automatically recognized AMM pair.
    /// @dev Automatic recognition compares runtime code hash with the immutable primary pair
    /// and therefore introduces no router, factory, or pair calls into the transfer path.
    /// @param account Address to inspect.
    /// @return True if the address is a registered pair or matches the primary pair implementation.
    function _isAmmPair(address account) internal view returns (bool) {
        return isPair[account] || account.codehash == primaryPairCodeHash;
    }

    /// @inheritdoc ERC20
    /// @notice Performs the internal VLT balance update with VoltPay transfer rules.
    /// @dev Applies launch restrictions, wallet/transaction limits, and buy/sell fees
    /// before delegating balance updates to the base ERC-20 implementation.
    function _update(address from, address to, uint256 amount) internal override {
        /// @dev Mint and burn balance updates bypass trading, limit, and fee checks.
        if (from == address(0) || to == address(0)) {
            super._update(from, to, amount);
            return;
        }

        /// @dev Internal router-driven balance updates bypass normal transfer restrictions.
        if (_inSwap) {
            super._update(from, to, amount);
            return;
        }

        /// @dev Before launch, transfers are restricted to explicitly authorized addresses.
        if (!tradingEnabled) {
            require(
                from == owner() ||
                    to == owner() ||
                    from == address(this) ||
                    to == address(this),
                "trading not active"
            );
        }

        bool isBuy = _isAmmPair(from);
        bool isSell = _isAmmPair(to);

        /// @dev Applies transaction and wallet limits until they are permanently removed.
        if (!limitsRemoved) {
            /// @dev Enforces buy transaction and recipient-wallet limits.
            if (isBuy && !isLimitExempt[to]) {
                require(amount <= maxTx, "tx limit");
                require(balanceOf(to) + amount <= maxWallet, "wallet limit");
            }

            /// @dev Enforces the transaction limit on non-exempt sells.
            if (isSell && !isLimitExempt[from]) {
                require(amount <= maxTx, "sell limit");
            }
        }

        uint256 feeAmount = 0;

        /// @dev Calculates buy or sell fees only when neither side is fee exempt.
        if (!isFeeExempt[from] && !isFeeExempt[to]) {
            /// @dev Applies the configured buy fee to pair-originated transfers.
            if (isBuy) {
                feeAmount = (amount * buyFee) / 10_000;
            /// @dev Applies the configured sell fee to pair-destination transfers.
            } else if (isSell) {
                feeAmount = (amount * sellFee) / 10_000;
            }

            /// @dev Moves the calculated fee into the contract before forwarding the net transfer.
            if (feeAmount > 0) {
                super._update(from, address(this), feeAmount);
                amount -= feeAmount;
            }
        }

        super._update(from, to, amount);
    }

    // =========================
    // SWAP LOGIC
    // =========================

    /// @notice Processes accumulated VLT fees into liquidity and treasury BNB.
    /// @dev Processing is separated from transfers and requires explicit slippage and deadline bounds.
    /// @param requestedSwapAmount Exact VLT amount requested for processing.
    /// @param amountOutMin Minimum BNB output accepted for the token swap.
    /// @param amountTokenMin Minimum token amount accepted when adding liquidity.
    /// @param amountNativeMin Minimum BNB amount accepted when adding liquidity.
    /// @param deadline External router deadline, additionally bounded by MAX_PROCESS_DEADLINE.
    function processFees(uint256 requestedSwapAmount, uint256 amountOutMin, uint256 amountTokenMin, uint256 amountNativeMin, uint256 deadline) external nonReentrant onlyFeeProcessor lockSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        require(contractTokenBalance > 0, "No tokens to swap");
        require(requestedSwapAmount > 0, "Swap amount zero");
        require(requestedSwapAmount <= contractTokenBalance, "Amount exceeds balance");
        require(requestedSwapAmount <= maxSwapAmount, "Amount exceeds max swap");
        require(requestedSwapAmount >= swapThreshold || requestedSwapAmount == contractTokenBalance, "Below swap threshold");
        require(amountOutMin > 0, "Min output zero");
        require(amountTokenMin > 0, "Token min zero");
        require(amountNativeMin > 0, "Native min zero");
        if (deadline < block.timestamp) {
            revert("Deadline expired");
        }

        if (deadline > block.timestamp + MAX_PROCESS_DEADLINE) {
            revert("Deadline too far");
        }

        _swap(requestedSwapAmount, amountOutMin, amountTokenMin, amountNativeMin, deadline);
    }

    /// @notice Executes the internal fee-processing sequence.
    /// @dev Executes fee conversion, liquidity addition, and treasury accounting.
    /// @param requestedSwapAmount Exact VLT amount being processed.
    /// @param amountOutMin Minimum BNB output accepted for the token swap.
    /// @param amountTokenMin Minimum token amount accepted for liquidity.
    /// @param amountNativeMin Minimum BNB amount accepted for liquidity.
    /// @param deadline Router execution deadline.
    function _swap(uint256 requestedSwapAmount, uint256 amountOutMin, uint256 amountTokenMin, uint256 amountNativeMin, uint256 deadline) internal {




        // For a 50/50 overall fee split:
        // 25% of tokens remain as the token side of LP,
        // 75% are swapped; one third of received BNB funds the BNB side of LP.
        uint256 lpTokens = (requestedSwapAmount * LIQUIDITY_SHARE) / 100 / 2;
        uint256 tokensToSwap = requestedSwapAmount - lpTokens;
        require(lpTokens > 0 && tokensToSwap > 0, "Process amount too small");

        uint256 nativeReceived = _swapTokensForNative(tokensToSwap, amountOutMin, deadline);

        (uint256 tokensUsedForLiquidity, uint256 nativeUsedForLiquidity, uint256 liquidityMinted) = _addLiquidity(lpTokens, nativeReceived / 3, amountTokenMin, amountNativeMin, deadline);

        // Pull-payment accounting: _swap never calls the treasury.
        // This removes an untrusted external native-coin call from transfer flow.
        uint256 currentTreasuryAmount = nativeReceived - nativeUsedForLiquidity;

        /// @dev Accrues the treasury share in the pull-payment ledger when non-zero.
        if (currentTreasuryAmount > 0) {
            pendingTreasuryBNB += currentTreasuryAmount;
            emit TreasuryAccrued(currentTreasuryAmount, pendingTreasuryBNB);
        }

        emit SwapAndLiquify(
            tokensToSwap,
            nativeReceived,
            tokensUsedForLiquidity,
            nativeUsedForLiquidity,
            liquidityMinted,
            DEAD
        );
    }

    /// @notice Adds VLT and BNB liquidity through the immutable router.
    /// @dev Adds VLT/BNB liquidity and sends the resulting LP tokens to DEAD.
    /// @param tokenAmount Desired VLT amount for the liquidity operation.
    /// @param nativeAmount Desired BNB amount for the liquidity operation.
    /// @param amountTokenMin Minimum VLT amount accepted by the router.
    /// @param amountNativeMin Minimum BNB amount accepted by the router.
    /// @param deadline Router execution deadline.
    /// @return tokensUsed Actual VLT amount consumed by the router.
    /// @return nativeUsed Actual BNB amount consumed by the router.
    /// @return liquidityMinted LP-token amount minted to DEAD.
    function _addLiquidity(uint256 tokenAmount, uint256 nativeAmount, uint256 amountTokenMin, uint256 amountNativeMin, uint256 deadline) internal returns (uint256 tokensUsed, uint256 nativeUsed, uint256 liquidityMinted) {
        if (tokenAmount == 0 || nativeAmount == 0) return (0, 0, 0);

        _approve(address(this), address(router), tokenAmount);

        (tokensUsed, nativeUsed, liquidityMinted) = router.addLiquidityETH{value: nativeAmount}(
            address(this),
            tokenAmount,
            amountTokenMin,
            amountNativeMin,
            DEAD,
            deadline
        );

        _approve(address(this), address(router), 0);
    }

    /// @notice Swaps an exact VLT amount for BNB during fee processing.
    /// @dev Swaps an exact VLT amount for BNB through the immutable router.
    /// @param tokenAmount Exact VLT amount to swap.
    /// @param amountOutMin Minimum BNB output accepted from the router.
    /// @param deadline Router execution deadline.
    /// @return nativeReceived Actual BNB received by this contract.
    function _swapTokensForNative(uint256 tokenAmount, uint256 amountOutMin, uint256 deadline) internal returns (uint256 nativeReceived) {
        _approve(address(this), address(router), tokenAmount);

        uint256 nativeBalanceBeforeSwap = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            amountOutMin,
            path,
            address(this),
            deadline
        );

        _approve(address(this), address(router), 0);
        nativeReceived = address(this).balance - nativeBalanceBeforeSwap;
    }

    /// @notice Accepts BNB required for router swaps, liquidity operations, and treasury accounting.
    /// @dev The contract must be able to receive native BNB from the PancakeSwap-compatible router.
    receive() external payable {}
}
