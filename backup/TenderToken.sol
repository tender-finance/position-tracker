// SPDX-License-Identifier: BSD-3-Clause
pragma solidity >=0.8.10;

import {IComptroller} from 'tender/interfaces/Comptroller.sol';
import {ICToken} from 'tender/interfaces/CToken.sol';
import {console2} from 'forge-std/console2.sol';
import {CTokenInterface, CTokenStorage} from './CTokenInterfaces.sol';
// import {ERC20} from 'openzeppelin-contracts/contracts/ERC20/ERC20.sol';
import {ERC20} from 'oz/token/ERC20/ERC20.sol';
import {CErc20} from './CErc20.sol';

library LibTenderToken {
  struct TenderTokenData {
    ICToken CTokenUnderlying;
    uint balance;
    uint supplyAmount; // balance/supplyAmount = leverage
    address owner;
  }
  // function tokenCall(TenderTokenData position, bytes _data) internal {
    // console2.logBytes(msg.data);
  // }
}

contract TenderToken is CTokenInterface, CErc20Interface {
  ICToken public uToken;
  constructor(
    string memory _name,
    string memory _symbol,
    ICToken _uToken
  ) ERC20(_name, _symbol) {
    uToken = _uToken;
  }
  fallback() external payable {
    console2.logBytes(msg.data);
  }
}

contract TenderTokenManager {
  address public prevImpl;
  address public impl;
  mapping(address => bool) handlers;
  mapping(address => uint) balances;
  mapping(address => LibTenderToken.TenderTokenData) public positions;


  receive() external payable {
    console2.logBytes(msg.data);
  }
  fallback() external payable {
    console2.logBytes(msg.data);
    // require(msg.value == 0,"CErc20Delegator:fallback: cannot send value to fallback");
    //
    // // delegate all other functions to current implementation
    // (bool success, ) = implementation.delegatecall(msg.data);
    //
    // assembly {
    //   let free_mem_ptr := mload(0x40)
    //   returndatacopy(free_mem_ptr, 0, returndatasize())
    //
    //   switch success
    //   case 0 { revert(free_mem_ptr, returndatasize()) }
    //   default { return(free_mem_ptr, returndatasize()) }
    // }
  }
}
contract TenderTokenManager {
  mapping(ICToken => TenderToken) public stakedTokensMap;

  constructor() {}
  function mintForAccount(uint sypplyAmount, uint recieveAmount, ICToken _ctoken, address ) public {
    // positions[_account] = LibTenderToken.TenderTokenData(_ctoken, );
  }
  function mint() public {

  }
  receive() external payable {}

}
