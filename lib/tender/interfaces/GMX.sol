//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IERC20} from './Tokens.sol';

interface IStakedGlp is IERC20 {
  function glp() external view returns (address);
  function glpManager() external view returns (IGlpManager);
  function stakedGlpTracker() external view returns (address);
  function feeGlpTracker() external view returns (address);
}

interface IRewardTracker {
  function balanceOf(address _account) external view returns (uint256);
  function approve(address _spender, uint256 _amount) external returns (bool);
  function depositBalances(address _account, address _depositToken) external view returns (uint256);
  function stakedAmounts(address _account) external view returns (uint256);
  function updateRewards() external;
  function stake(address _depositToken, uint256 _amount) external;
  function stakeForAccount(address _fundingAccount, address _account, address _depositToken, uint256 _amount) external;
  function unstake(address _depositToken, uint256 _amount) external;
  function unstakeForAccount(address _account, address _depositToken, uint256 _amount, address _receiver) external;
  function tokensPerInterval() external view returns (uint256);
  function claim(address _receiver) external returns (uint256);
  function claimForAccount(address _account, address _receiver) external returns (uint256);
  function claimable(address _account) external view returns (uint256);
  function averageStakedAmounts(address _account) external view returns (uint256);
  function cumulativeRewards(address _account) external view returns (uint256);
}

interface IGlpManager {
  function glp() external view returns (address);
  function usdg() external view returns (address);
  function vault() external view returns (IGmxVault);
  function cooldownDuration() external returns (uint256);
  function getAumInUsdg(bool maximise) external view returns (uint256);
  function lastAddedAt(address _account) external returns (uint256);
  function addLiquidity(address _token, uint256 _amount, uint256 _minUsdg, uint256 _minGlp) external returns (uint256);
  function addLiquidityForAccount(address _fundingAccount, address _account, address _token, uint256 _amount, uint256 _minUsdg, uint256 _minGlp) external returns (uint256);
  function removeLiquidity(address _tokenOut, uint256 _glpAmount, uint256 _minOut, address _receiver) external returns (uint256);
  function removeLiquidityForAccount(address _account, address _tokenOut, uint256 _glpAmount, uint256 _minOut, address _receiver) external returns (uint256);
  function setShortsTrackerAveragePriceWeight(uint256 _shortsTrackerAveragePriceWeight) external;
  function setCooldownDuration(uint256 _cooldownDuration) external;
}

interface IRewardRouterV2 {
  function stakedGmxTracker() external view returns (address);
  function bonusGmxTracker() external view returns (address);
  function feeGmxTracker() external view returns (address);
  function stakedGlpTracker() external view returns (address);
  function feeGlpTracker() external view returns (address);
  function glpManager() external view returns (address);
  function handleRewards(
    bool _shouldClaimGmx,
    bool _shouldStakeGmx,
    bool _shouldClaimEsGmx,
    bool _shouldStakeEsGmx,
    bool _shouldStakeMultiplierPoints,
    bool _shouldClaimWeth,
    bool _shouldConvertWethToEth
  ) external;
  function signalTransfer(address _receiver) external;
  function mintAndStakeGlp(address _token, uint256 _amount, uint256 _minUsdg, uint256 _minGlp) external returns (uint256);
  function mintAndStakeGlpETH(uint256 _minUsdg, uint256 _minGlp) external payable returns (uint256);
  function stakeGmx(uint256 amount) external;
  function unstakeGmx(uint256 amount) external;
}

interface IGmxVault {
  function isInitialized() external view returns (bool);
  function isSwapEnabled() external view returns (bool);
  function isLeverageEnabled() external view returns (bool);

  function setVaultUtils(address _vaultUtils) external;
  function setError(uint256 _errorCode, string calldata _error) external;

  function router() external view returns (address);
  function usdg() external view returns (address);
  function gov() external view returns (address);

  function whitelistedTokenCount() external view returns (uint256);
  function maxLeverage() external view returns (uint256);

  function minProfitTime() external view returns (uint256);
  function hasDynamicFees() external view returns (bool);
  function fundingInterval() external view returns (uint256);
  function totalTokenWeights() external view returns (uint256);
  function getTargetUsdgAmount(address _token) external view returns (uint256);

  function inManagerMode() external view returns (bool);
  function inPrivateLiquidationMode() external view returns (bool);

  function maxGasPrice() external view returns (uint256);

  function approvedRouters(address _account, address _router) external view returns (bool);
  function isLiquidator(address _account) external view returns (bool);
  function isManager(address _account) external view returns (bool);

  function minProfitBasisPoints(address _token) external view returns (uint256);
  function tokenBalances(address _token) external view returns (uint256);
  function lastFundingTimes(address _token) external view returns (uint256);

  function setMaxLeverage(uint256 _maxLeverage) external;
  function setInManagerMode(bool _inManagerMode) external;
  function setManager(address _manager, bool _isManager) external;
  function setIsSwapEnabled(bool _isSwapEnabled) external;
  function setIsLeverageEnabled(bool _isLeverageEnabled) external;
  function setMaxGasPrice(uint256 _maxGasPrice) external;
  function setUsdgAmount(address _token, uint256 _amount) external;
  function setBufferAmount(address _token, uint256 _amount) external;
  function setMaxGlobalShortSize(address _token, uint256 _amount) external;
  function setInPrivateLiquidationMode(bool _inPrivateLiquidationMode) external;
  function setLiquidator(address _liquidator, bool _isActive) external;

  function setFundingRate(uint256 _fundingInterval, uint256 _fundingRateFactor, uint256 _stableFundingRateFactor) external;

  function setFees(
    uint256 _taxBasisPoints,
    uint256 _stableTaxBasisPoints,
    uint256 _mintBurnFeeBasisPoints,
    uint256 _swapFeeBasisPoints,
    uint256 _stableSwapFeeBasisPoints,
    uint256 _marginFeeBasisPoints,
    uint256 _liquidationFeeUsd,
    uint256 _minProfitTime,
    bool _hasDynamicFees
  ) external;

  function setTokenConfig(
    address _token,
    uint256 _tokenDecimals,
    uint256 _redemptionBps,
    uint256 _minProfitBps,
    uint256 _maxUsdgAmount,
    bool _isStable,
    bool _isShortable
  ) external;

  function setPriceFeed(address _priceFeed) external;
  function withdrawFees(address _token, address _receiver) external returns (uint256);

  function directPoolDeposit(address _token) external;
  function buyUSDG(address _token, address _receiver) external returns (uint256);
  function sellUSDG(address _token, address _receiver) external returns (uint256);
  function swap(address _tokenIn, address _tokenOut, address _receiver) external returns (uint256);
  function increasePosition(address _account, address _collateralToken, address _indexToken, uint256 _sizeDelta, bool _isLong) external;
  function decreasePosition(address _account, address _collateralToken, address _indexToken, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong, address _receiver) external returns (uint256);
  function validateLiquidation(address _account, address _collateralToken, address _indexToken, bool _isLong, bool _raise) external view returns (uint256, uint256);
  function liquidatePosition(address _account, address _collateralToken, address _indexToken, bool _isLong, address _feeReceiver) external;
  function tokenToUsdMin(address _token, uint256 _tokenAmount) external view returns (uint256);

  function priceFeed() external view returns (address);
  function fundingRateFactor() external view returns (uint256);
  function stableFundingRateFactor() external view returns (uint256);
  function cumulativeFundingRates(address _token) external view returns (uint256);
  function getNextFundingRate(address _token) external view returns (uint256);
  function getFeeBasisPoints(address _token, uint256 _usdgDelta, uint256 _feeBasisPoints, uint256 _taxBasisPoints, bool _increment) external view returns (uint256);

  function liquidationFeeUsd() external view returns (uint256);
  function taxBasisPoints() external view returns (uint256);
  function stableTaxBasisPoints() external view returns (uint256);
  function mintBurnFeeBasisPoints() external view returns (uint256);
  function swapFeeBasisPoints() external view returns (uint256);
  function stableSwapFeeBasisPoints() external view returns (uint256);
  function marginFeeBasisPoints() external view returns (uint256);

  function allWhitelistedTokensLength() external view returns (uint256);
  function allWhitelistedTokens(uint256) external view returns (address);
  function whitelistedTokens(address _token) external view returns (bool);
  function stableTokens(address _token) external view returns (bool);
  function shortableTokens(address _token) external view returns (bool);
  function feeReserves(address _token) external view returns (uint256);
  function globalShortSizes(address _token) external view returns (uint256);
  function globalShortAveragePrices(address _token) external view returns (uint256);
  function maxGlobalShortSizes(address _token) external view returns (uint256);
  function tokenDecimals(address _token) external view returns (uint256);
  function tokenWeights(address _token) external view returns (uint256);
  function guaranteedUsd(address _token) external view returns (uint256);
  function poolAmounts(address _token) external view returns (uint256);
  function bufferAmounts(address _token) external view returns (uint256);
  function reservedAmounts(address _token) external view returns (uint256);
  function usdgAmounts(address _token) external view returns (uint256);
  function maxUsdgAmounts(address _token) external view returns (uint256);
  function getRedemptionAmount(address _token, uint256 _usdgAmount) external view returns (uint256);
  function getMaxPrice(address _token) external view returns (uint256);
  function getMinPrice(address _token) external view returns (uint256);

  function getDelta(address _indexToken, uint256 _size, uint256 _averagePrice, bool _isLong, uint256 _lastIncreasedTime) external view returns (bool, uint256);
  function getPosition(address _account, address _collateralToken, address _indexToken, bool _isLong) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256);
}
