// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import {CTokenInterface, CTokenStorage} from 'tender/CToken/CTokenInterfaces.sol';
import {IComptroller} from 'tender/interfaces/Comptroller.sol';
import {ICToken} from 'tender/interfaces/CToken.sol';
import {Exponential as Expo} from './Exponential.sol';
import {ERC721} from 'oz/token/ERC721/ERC721.sol';
import {SafeMath} from 'oz/utils/math/SafeMath.sol';
import {Error} from './ErrorReporter.sol';

/* @title PositionTracker
* @dev Tracks the position of vault deposited cTokens
* @dev leverage*supplyAmount = totalPostionValue
* @dev
oracle.getUnderlyingPrice(cTokenUnderlying)
.mul(cTokenUnderlying.decimals())
.div(cTokenUnderlying.exchangeRateCurrent())
*/

struct PositionArgs {
  uint    supplyAmount;        // number of cTokens to supply
  uint    leverage;            // multiplier
  address receiver;            // address initializing the mint
  address cTokenUnderlying;    // cToken to supply
}

library PositionParameters {
  using SafeMath for uint256;

  function encodeURIParams(PositionArgs memory params) public view returns (bytes memory) {
    require(params.leverage >= 1, 'leverage must be greater than 1');
    require(params.supplyAmount > 0, 'supplyAmount must be greater than 0');
    require(params.receiver != address(0), 'receiver must be non-zero address');
    require(ICToken(params.cTokenUnderlying).isCToken(), 'cTokenUnderlying must be a cToken');

    return abi.encode(
      params.supplyAmount,
      params.leverage,
      params.receiver,
      params.cTokenUnderlying
    );
  }

  function decodeURIParams(bytes memory uri) public pure returns (PositionArgs memory params) {
    (
      params.supplyAmount,
      params.leverage,
      params.receiver,
      params.cTokenUnderlying
    ) = abi.decode(
      uri,
      (uint, uint, address, address)
    );
    return params;
  }
}
