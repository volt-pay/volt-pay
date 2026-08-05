// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256, uint256, uint256);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

/// @title VoltPay V2 Clean Launch Contract - Secure Production Version
contract VoltPayV2 is ERC20, Ownable2Step {
    using SafeERC20 for IERC20;

    uint256 public constant TOTAL_SUPPLY = 200_000_000 * 10**18;

    // Fees (100 = 1%)
    uint256 public buyFee = 200;   // 2%
    uint256 public sellFee = 400;  // 4%

    uint256 public constant LIQUIDITY_SHARE = 50;
    uint256 public constant TREASURY_SHARE = 50;

    uint256 public constant MAX_TX = 30_000 * 10**18;
    uint256 public constant MAX_WALLET = 30_000 * 10**18;

    // Сделано изменяемым через сетинги
    uint256 public swapThreshold = 12_000 * 10**18;
    uint256 public maxSwapAmount = 30_000 * 10**18;

    IUniswapV2Router02 public immutable router;
    address public immutable pair;
    address public immutable treasury;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    bool public tradingEnabled;
    bool public limitsRemoved;
    bool public feesLocked;

    bool private inSwap;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isLimitExempt;
    mapping(address => bool) public isPair;

    modifier lockSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event TradingEnabled();
    event LimitsRemoved();
    event FeesLocked();
    event FeesUpdated(uint256 buyFee, uint256 sellFee);
    event SwapSettingsUpdated(uint256 threshold, uint256 maxAmount);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity, address lpRecipient);

    constructor(address _router, address _treasury)
        ERC20("VoltPay", "VLT")
        Ownable(msg.sender)
    {
        require(_router != address(0), "Router zero");
        require(_treasury != address(0), "Treasury zero");

        router = IUniswapV2Router02(_router);
        treasury = _treasury;

        address _pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        pair = _pair;
        isPair[_pair] = true;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[_treasury] = true;

        isLimitExempt[msg.sender] = true;
        isLimitExempt[address(this)] = true;
        isLimitExempt[_treasury] = true;
        isLimitExempt[_pair] = true;

        _mint(msg.sender, TOTAL_SUPPLY);
    }

    // =========================
    // OWNER CONTROLS & SAFETY
    // =========================

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "enabled");
        tradingEnabled = true;
        emit TradingEnabled();
    }

    function removeLimits() external onlyOwner {
        require(!limitsRemoved, "removed");
        limitsRemoved = true;
        emit LimitsRemoved();
    }

    function reduceFees(uint256 _buy, uint256 _sell) external onlyOwner {
        require(!feesLocked, "locked");
        require(_buy <= buyFee && _sell <= sellFee, "only reduce");

        buyFee = _buy;
        sellFee = _sell;

        emit FeesUpdated(_buy, _sell);
    }

    function lockFees() external onlyOwner {
        require(!feesLocked, "locked");
        feesLocked = true;
        emit FeesLocked();
    }

    function setSwapSettings(uint256 _threshold, uint256 _maxAmount) external onlyOwner {
        require(_threshold > 0, "Threshold low");
        require(_maxAmount >= _threshold, "Max less than threshold");
        swapThreshold = _threshold;
        maxSwapAmount = _maxAmount;
        emit SwapSettingsUpdated(_threshold, _maxAmount);
    }

    // Запрет на renounceOwnership до выполнения условий запуска экосистемы
    function renounceOwnership() public override onlyOwner {
        require(tradingEnabled, "Trading must be enabled first");
        require(feesLocked, "Fees must be locked first");
        super.renounceOwnership();
    }

    // =========================
    // RESCUE FUNCTIONS
    // =========================

    function rescueBNB() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No BNB");
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Rescue failed");
    }

    function rescueTokens(address _token) external onlyOwner {
        require(_token != address(this), "Cannot rescue native VLT tokens");
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance > 0, "No tokens");
        IERC20(_token).safeTransfer(owner(), balance);
    }

    // =========================
    // TRANSFER LOGIC
    // =========================

    function _update(address from, address to, uint256 amount) internal override {
        if (from == address(0) || to == address(0)) {
            super._update(from, to, amount);
            return;
        }

        if (inSwap) {
            super._update(from, to, amount);
            return;
        }

        if (!tradingEnabled) {
            require(
                from == owner() ||
                to == owner() ||
                from == address(this) ||
                to == address(this),
                "trading not active"
            );
        }

        bool isBuy = isPair[from];
        bool isSell = isPair[to];

        if (
            isSell &&
            !isFeeExempt[from] &&
            balanceOf(address(this)) >= swapThreshold
        ) {
            _swap(swapThreshold);
        }

        if (!limitsRemoved) {
            if (isBuy && !isLimitExempt[to]) {
                require(amount <= MAX_TX, "tx limit");
                require(balanceOf(to) + amount <= MAX_WALLET, "wallet limit");
            }

            if (isSell && !isLimitExempt[from]) {
                require(amount <= MAX_TX, "sell limit");
            }
        }

        uint256 feeAmount;

        if (!isFeeExempt[from] && !isFeeExempt[to]) {
            if (isBuy) {
                feeAmount = (amount * buyFee) / 10_000;
            } else if (isSell) {
                feeAmount = (amount * sellFee) / 10_000;
            }

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

    function manualSwap() external onlyOwner {
        uint256 balance = balanceOf(address(this));
        require(balance > 0, "No tokens to swap");
        _swap(balance);
    }

    function _swap(uint256 swapAmount) internal lockSwap {
        uint256 balance = balanceOf(address(this));
        if (balance == 0) return;

        if (swapAmount > balance) {
            swapAmount = balance;
        }

        if (swapAmount > maxSwapAmount) {
            swapAmount = maxSwapAmount;
        }

        uint256 lpTokens = (swapAmount * LIQUIDITY_SHARE) / 100 / 2;
        uint256 toSwap = swapAmount - lpTokens;

        _approve(address(this), address(router), toSwap);

        uint256 beforeBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            toSwap,
            0, // amountOutMin = 0 (на старте допустимо, проскальзывание не контролируем)
            path,
            address(this),
            block.timestamp
        );

        uint256 received = address(this).balance - beforeBalance;

        uint256 lpEth = received / 3;
        uint256 treasuryEth = received - lpEth;

        if (lpTokens > 0 && lpEth > 0) {
            _approve(address(this), address(router), lpTokens);
            
            router.addLiquidityETH{value: lpEth}(
                address(this),
                lpTokens,
                0,
                0,
                DEAD, // ТЕПЕРЬ СТРОГО НА DEAD-АДРЕС
                block.timestamp
            );
        }

        if (treasuryEth > 0) {
            (bool success,) = payable(treasury).call{value: treasuryEth}("");
            require(success, "Treasury transfer failed"); // ОБЯЗАТЕЛЬНАЯ ПРОВЕРКА ОСТАВЛЕНА
        }

        emit SwapAndLiquify(toSwap, received, lpTokens, DEAD);
    }

    receive() external payable {}
}
