// SPDX-License-Identifier: BSD-3-Clause
pragma solidity >=0.8.0;

import {IComptroller} from "./Comptroller.sol";
import {InterestRateModel} from "./../helpers/InterestRateModel.sol";
import {IERC20} from "oz/token/ERC20/ERC20.sol";

import {
  IRewardRouterV2,
  IStakedGlp,
  IRewardTracker,
  IGlpManager
} from './GMX.sol';

interface ICToken {
  // CERC20 functions
  function underlying() external view returns (IERC20);
  function mint(uint256 mintAmount) external returns (uint);
  function redeem(uint256 redeemTokens) external returns (uint);
  function redeemUnderlying(uint256 redeemAmount) external returns (uint); 
  function redeemUnderlyingForUser(uint256 redeemAmount, address user) external returns (uint); 
  function borrow(uint256 borrowAmount) external returns (uint);
  function repayBorrow(uint256 repayAmount) external returns (uint);
  function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint);
  function liquidateBorrow(address borrower, uint256 repayAmount, address cTokenCollateral) external returns (uint);
  function depositNFT(address _NFTAddress, uint256 _TokenID) external;
  function withdrawNFT(address _NFTAddress, uint256 _TokenID) external;
  function compound() external returns (uint256);

  // CToken functions
  function glpManager() external view returns(IGlpManager);
  function gmxToken() external view returns(IERC20);
  function glpRewardRouter() external view returns(IRewardRouterV2);
  function stakedGLP() external view returns(IStakedGlp);
  function sbfGMX() external view returns(IRewardTracker);
  function stakedGmxTracker() external view returns(IRewardTracker);

  function _notEntered() external view returns(bool);

  function isGLP() external view returns(bool);
  function autocompound() external view returns(bool);
  function glpBlockDelta() external view returns(uint);
  function lastGlpDepositAmount() external view returns(uint);

  function comptroller() external view returns(IComptroller);
  function interestRateModel() external view returns(InterestRateModel);

  function name() external view returns(string memory);
  function symbol() external view returns(string memory);
  function decimals() external view returns(uint8);
  function admin() external view returns(address);
  function pendingAdmin() external view returns(address);
  function initialExchangeRateMantissa() external view returns(uint);
  function reserveFactorMantissa() external view returns(uint);
  function accrualBlockNumber() external view returns(uint);
  function borrowIndex() external view returns(uint);
  function totalBorrows() external view returns(uint);
  function totalReserves() external view returns(uint);
  function totalSupply() external view returns(uint);
  function withdrawFee() external view returns(uint256);
  function performanceFee() external view returns(uint256);
  function exchangeRateBefore() external view returns(uint256);
  function blocksBetweenRateChange() external view returns(uint256);
  function prevExchangeRate() external view returns(uint);
  function depositsDuringLastInterval() external view returns(uint);
  function isCToken() external view returns(bool);

  function performanceFeeMAX() external view returns(uint256);
  function withdrawFeeMAX() external view returns(uint256);
  function autoCompoundBlockThreshold() external view returns(uint256);
  function transfer(address dst, uint amount) external returns (bool);
  function transferFrom(address src, address dst, uint amount) external returns (bool);
  function approve(address spender, uint amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint);
  function balanceOf(address owner) external view returns (uint);
  function balanceOfUnderlying(address owner) external returns (uint);
  function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
  function borrowRatePerBlock() external view returns (uint);
  function supplyRatePerBlock() external view returns (uint);
  function totalBorrowsCurrent() external returns (uint);
  function borrowBalanceCurrent(address account) external returns (uint);
  function borrowBalanceStored(address account) external view returns (uint);
  function exchangeRateCurrent() external returns (uint);
  function exchangeRateStored() external view returns (uint);
  function getCash() external view returns (uint);
  function accrueInterest() external returns (uint);
  function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);
}
