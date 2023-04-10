// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;
import {PositionArgs} from './PositionParameters.sol';
import {IComptroller} from 'tender/interfaces/Comptroller.sol';
import {ICToken} from 'tender/interfaces/CToken.sol';
import {Exp, Exponential} from './Exponential.sol';
import {SafeMath} from 'oz/utils/math/SafeMath.sol';
import {Error} from './ErrorReporter.sol';

struct PositionLiquidityVars {
  uint256 sumCollateral;
  uint256 sumBorrowPlusEffects;
  uint256 cTokenBalance;
  uint256 borrowBalance;
  uint256 exchangeRateMantissa;
  uint256 oraclePriceMantissa;
  Exp collateralFactor;
  Exp exchangeRate;
  Exp oraclePrice;
  Exp tokensToDenom;
}

library PositionLiquidity {
  using SafeMath for uint256;
  using Exponential for Exp;
  /*if this is a liquidation check:
    collateral factor = liq threshold */
  function getCollateralFactor(
    ICToken asset,
    address account,
    bool liquidation
  ) public view returns (Exp memory) {
    IComptroller comptroller = IComptroller(address(asset.comptroller()));

    if(liquidation) {
      return comptroller.getIsAccountVip(account)
        ? Exp({
          mantissa: comptroller.markets(address(asset))
          .liquidationThresholdMantissaVip
        })
        : Exp({
          mantissa: comptroller.markets(address(asset))
          .liquidationThresholdMantissa
        });
    }
    return comptroller.getIsAccountVip(account)
      ? Exp({
        mantissa: comptroller.markets(
          address(asset)
        ).collateralFactorMantissaVip
      })
      : Exp ({
        mantissa: comptroller.markets(address(asset))
        .collateralFactorMantissa
      });
  }

  /* @dev Calculates the position liquidity of a user's account position:
   * This function the unitroller must check to see if the account has 1 or more positions
   * and then call this function for each position.
   * Since this 
   */
  function getPositionLiquidity(
    PositionArgs memory params,
    bool liquidation
  ) public returns (
    uint err,
    uint liquidity,
    uint shortfall
  ) {
    address account = params.receiver;
    ICToken asset = ICToken(params.cTokenUnderlying);

    PositionLiquidityVars memory vars; // Holds all our calculation results
    vars.cTokenBalance = params.supplyAmount.mul(params.leverage);
    vars.borrowBalance = vars.cTokenBalance.sub(params.supplyAmount);
    vars.exchangeRateMantissa = asset.exchangeRateCurrent();
    vars.collateralFactor = getCollateralFactor(asset, account, liquidation);
    vars.exchangeRate = Exp({mantissa: vars.exchangeRateMantissa});
    IComptroller comptroller = IComptroller(address(asset.comptroller()));
    vars.oraclePriceMantissa = comptroller.oracle().getUnderlyingPrice(asset);

    if (vars.oraclePriceMantissa == 0) {
      return (uint(Error.PRICE_ERROR), 0, 0);
    }

    // Pre-compute a conversion factor from tokens -> usdc 18 dec (normalized price value)
    vars.tokensToDenom = Exponential.mul_(
      Exponential.mul_(vars.collateralFactor, vars.exchangeRate),
      vars.oraclePrice
    );
    // sumCollateral += tokensToDenom * cTokenBalance;
    vars.sumCollateral = Exponential.mul_ScalarTruncateAddUInt(
      vars.tokensToDenom,
      vars.cTokenBalance,
      vars.sumCollateral
    );
    // sumBorrowPlusEffects += oraclePrice * borrowBalance
    vars.sumBorrowPlusEffects = Exponential.mul_ScalarTruncateAddUInt(
      vars.oraclePrice,
      vars.borrowBalance,
      vars.sumBorrowPlusEffects
    );

    return (err, liquidity, shortfall);
  }
}
/* this code is used to check to see hypothetical effect. May be useful for checking what their ending position should be*/
//     // Calculate effects of interacting with cTokenModify
//     if (asset == cTokenModify) {
//       // redeem effect
//       // sumBorrowPlusEffects += tokensToDenom * redeemTokens
//       vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.tokensToDenom, redeemTokens, vars.sumBorrowPlusEffects);
//
//       // borrow effect
//       // sumBorrowPlusEffects += oraclePrice * borrowAmount
//       vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(vars.oraclePrice, borrowAmount, vars.sumBorrowPlusEffects);
//     }
//   }
//
//   // These are safe, as the underflow condition is checked first
//   if (vars.sumCollateral > vars.sumBorrowPlusEffects) {
//     return (Error.NO_ERROR, vars.sumCollateral - vars.sumBorrowPlusEffects, 0);
//   } else {
//     return (Error.NO_ERROR, 0, vars.sumBorrowPlusEffects - vars.sumCollateral);
//   }
//   }
// }
