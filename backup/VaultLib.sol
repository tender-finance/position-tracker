// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {ComptrollerErrorReporter} from 'tender/helpers/ErrorReporter.sol';
import {ICToken} from 'tender/interfaces/CToken.sol';
import {IComptroller} from 'tender/interfaces/Comptroller.sol';
import {ITenderPriceOracle} from 'tender/interfaces/PriceOracle.sol';
import {ExponentialNoError as LibExp} from 'tender/helpers/ExponentialNoError.sol';

library LibTenderToken {
  struct AccountLiquidityLocalVars {
    uint sumCollateral;
    uint sumBorrowPlusEffects;
    uint cTokenBalance;
    uint borrowBalance;
    uint exchangeRateMantissa;
    uint oraclePriceMantissa;
    LibExp.Exp collateralFactor;
    LibExp.Exp exchangeRate;
    LibExp.Exp oraclePrice;
    LibExp.Exp tokensToDenom;
  }
  struct oldFactorsAndThresholds {
    uint oldCollateralFactorMantissa;
    uint oldCollateralFactorMantissaVip;
    uint oldLiquidationThresholdMantissa;
    uint oldLiquidationThresholdMantissaVip;
  }

}

contract TenderToken is ComptrollerErrorReporter {
  mapping(address => uint) public balances;
  ICToken public cTokenUnderlying;
  string public name;
  string public symbol;
  uint8 public decimals;
  constructor (ICToken _CTokenUnderylying) {
  }

  function mint(uint amount) public {
    cTokenUnderlying.transferFrom(msg.sender, address(this), amount);
    balances[msg.sender] += amount;
  }
  function redeem(uint amount) public {
    balances[msg.sender] -= amount;
    cTokenUnderlying.transfer(msg.sender, amount);
  }
  function getHypotheticalAccountLiquidityInternal(
      address account,
      ICToken cTokenModify,
      uint redeemTokens,
      uint borrowAmount,
      bool liquidation
  ) internal view returns (Error, uint, uint) {

      AccountLiquidityLocalVars memory vars; // Holds all our calculation results
      uint oErr;

      // For each asset the account is in
      CToken[] memory assets = accountAssets[account];
      for (uint i = 0; i < assets.length; i++) {
          CToken asset = assets[i];

          // Read the balances and exchange rate from the cToken
          (oErr, vars.cTokenBalance, vars.borrowBalance, vars.exchangeRateMantissa) = asset.getAccountSnapshot(account);
          if (oErr != 0) { // semi-opaque error code, we assume NO_ERROR == 0 is invariant between upgrades
              return (Error.SNAPSHOT_ERROR, 0, 0);
          }

          if(!liquidation){
              vars.collateralFactor = getIsAccountVip(account)
                  ? Exp({
                      mantissa: markets[address(asset)]
                          .collateralFactorMantissaVip
                  })
                  : Exp({
                      mantissa: markets[address(asset)].collateralFactorMantissa
                  });
          } else {
              vars.collateralFactor = getIsAccountVip(account)
              ? Exp({
                  mantissa: markets[address(asset)]
                      .liquidationThresholdMantissaVip
              })
              : Exp({
                  mantissa: markets[address(asset)]
                      .liquidationThresholdMantissa
              });
          }
          
          vars.exchangeRate = Exp({mantissa: vars.exchangeRateMantissa});

          // Get the normalized price of the asset
          vars.oraclePriceMantissa = oracle.getUnderlyingPrice(asset);
          if (vars.oraclePriceMantissa == 0) {
              return (Error.PRICE_ERROR, 0, 0);
          }
          vars.oraclePrice = Exp({mantissa: vars.oraclePriceMantissa});

          // Pre-compute a conversion factor from tokens -> ether (normalized price value)
          vars.tokensToDenom = mul_(mul_(vars.collateralFactor, vars.exchangeRate), vars.oraclePrice);

          // sumCollateral += tokensToDenom * cTokenBalance
          vars.sumCollateral = mul_ScalarTruncateAddUInt(vars.tokensToDenom, vars.cTokenBalance, vars.sumCollateral);

          // sumBorrowPlusEffects += oraclePrice * borrowBalance
          vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.oraclePrice, vars.borrowBalance, vars.sumBorrowPlusEffects);

          // Calculate effects of interacting with cTokenModify
          if (asset == cTokenModify) {
              // redeem effect
              // sumBorrowPlusEffects += tokensToDenom * redeemTokens
              vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.tokensToDenom, redeemTokens, vars.sumBorrowPlusEffects);

              // borrow effect
              // sumBorrowPlusEffects += oraclePrice * borrowAmount
              vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.oraclePrice, borrowAmount, vars.sumBorrowPlusEffects);
          }
      }

      // These are safe, as the underflow condition is checked first
      if (vars.sumCollateral > vars.sumBorrowPlusEffects) {
          return (Error.NO_ERROR, vars.sumCollateral - vars.sumBorrowPlusEffects, 0);
      } else {
          return (Error.NO_ERROR, 0, vars.sumBorrowPlusEffects - vars.sumCollateral);
      }
  }
}
