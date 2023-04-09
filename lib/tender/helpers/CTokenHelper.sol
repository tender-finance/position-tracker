// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;
import {IERC20, IWETH} from '../interfaces/Tokens.sol';
import {ICToken} from '../interfaces/CToken.sol';
import {Addresses} from 'tender/helpers/Addresses.sol';
import {SafeMath} from 'openzeppelin-contracts/contracts/utils/math/SafeMath.sol';
import {IComptroller} from '../interfaces/Comptroller.sol';
import {IGlpManager, IGmxVault, IRewardRouterV2} from '../interfaces/GMX.sol';
import {ITenderPriceOracle} from '../interfaces/TenderPriceOracle.sol';

contract CTokenHelper is Addresses {
  using SafeMath for uint;

  function getUnderlying(ICToken cToken) public view returns (IERC20) {
    return (cToken == tETH) ? wETH : ICToken(cToken).underlying();
  }

  function getCollateralFactor(ICToken cToken, bool vip) public view returns (uint) {
    (,uint collateralFactor,,uint collateralFactorVip,,,,) = unitroller.markets(address(cToken));
    return vip ? collateralFactorVip : collateralFactor;
  }

  function getLiquidationThreshold(ICToken cToken, bool vip) public view returns (uint) {
    (,,uint liqThreshold,uint liqThresholdVip,,,,) = unitroller.markets(address(cToken));
    return vip ? liqThresholdVip : liqThreshold;
  }

  function getUnderlyingPrice(ICToken cToken) public view returns (uint256) {
    ITenderPriceOracle oracle = unitroller.oracle();
    return oracle.getUnderlyingPrice(ICToken(cToken));
  }

  function getLeverageMultiplier(uint collateralFactor) public pure returns (uint) {
    uint totalValueThreshold = 1e18;
    uint maxValue = 100;
    uint totalValueDividend = totalValueThreshold.sub(collateralFactor).div(1e16);
    return maxValue.div(totalValueDividend);
  }
}
