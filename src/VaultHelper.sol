// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;
import {IERC20, IWETH} from 'tender/Tokens.sol';
import {ICToken} from 'tender/CToken.sol';
import {Addresses} from 'lib/helpers/Addresses.sol';
import {SafeMath} from 'lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol';
import {IComptroller} from 'tender/Comptroller.sol';
import {IGlpManager, IGmxVault, IRewardRouterV2} from 'tender/GMX.sol';
import {ITenderPriceOracle} from 'tender/TenderPriceOracle.sol';

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

contract GlpHelper is Addresses {
  using SafeMath for uint;

  function usdgAmounts(address token) public view returns (uint256){
    return glpVault.usdgAmounts(token); // weth 127657111,442541096364249993
  }

  function getAumInUsdg() public view returns (uint256){
    return glpManager.getAumInUsdg(true); // 428851069,305319770736134981
  }

  function getVaultPercentage(address token) public view returns (uint256){
    return usdgAmounts(token).mul(1e18).div(getAumInUsdg());
  }

  function getGlpPrice() public view returns (uint256){
    ITenderPriceOracle oracle = unitroller.oracle();
    return oracle.getGlpAum().mul(1e18).div(glpToken.totalSupply());
  }
}

contract VaultHelper is GlpHelper, CTokenHelper {
}
