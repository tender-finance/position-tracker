// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;
import 'openzeppelin-contracts/contracts/utils/math/SafeMath.sol';
import {
  ERC20Addresses,
  CompoundAddresses,
  GMXAddresses
} from './Addresses.sol';

contract GlpHelper is GMXAddresses {
  using SafeMath for uint;

  function getVaultPercentageCurrent(address token) public view returns (uint){
    return glpVault.usdgAmounts(token).mul(1e18).div(getGlpAum());
  }

  function getGlpSupply() public view returns (uint) {
    return glpToken.totalSupply();
  }

  function getGlpAum() public view returns (uint) {
    return glpManager.getAumInUsdg(true);
  }

  function getGlpPrice() public view returns (uint) {
    return getGlpAum().mul(1e18).div(getGlpSupply());
  }
}
