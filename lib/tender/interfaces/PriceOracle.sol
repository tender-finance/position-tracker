// SPDX-License-Identifier: BSD-3-Clause
pragma solidity >=0.8.0;
import {ICToken} from "./CToken.sol";
import {IERC20} from "./Tokens.sol";

interface ChainLinkPriceOracle {
  function latestAnswer() external view returns (uint256);
  function decimals() external view returns (uint8);
}

interface TenderPriceOracle {
  function getGlpSupply() external view returns (uint256);
  function getGlpAum() external view returns (uint256);
  function getGlpPrice() external view returns (uint256);
  function getUnderlyingDecimals(ICToken ctoken) external view returns (uint);
  function getUnderlyingPrice(ICToken ctoken) external view returns (uint);
  function getOracleDecimals(IERC20 token) external view returns (uint);
  function getUSDPrice(IERC20 token) external view returns (uint);
}
