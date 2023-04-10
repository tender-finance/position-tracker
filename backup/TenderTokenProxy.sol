pragma solidity >=0.8.10;
import "./TenderTokenInterfaces.sol";
import {IComptroller} from 'tender/interfaces/Comptroller.sol';
import {IERC20} from 'tender/interfaces/Tokens.sol';


contract TenderDelegator is CTokenInterface, CErc20Interface, CDelegatorInterface {
    constructor(
      address underlying_,
      IComptroller comptroller_,
      InterestRateModel interestRateModel_,
      uint initialExchangeRateMantissa_,
      string memory name_,
      string memory symbol_,
      uint8 decimals_,
      bool isGLP_,
      address payable admin_,
      address implementation_,
      bytes memory becomeImplementationData
    ){
        admin = payable(msg.sender);

        delegateTo(
          implementation_,
          abi.encodeWithSignature(
            "initialize(address,address,address,uint256,string,string,uint8,bool)",
            underlying_,
            comptroller_,
            interestRateModel_,
            initialExchangeRateMantissa_,
            name_,
            symbol_,
            decimals_,
            isGLP_
          )
        );

        _setImplementation(implementation_, false, becomeImplementationData);

        admin = admin_;
    }

    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData)override public {
        require(msg.sender == admin, "CErc20Delegator::_setImplementation: Caller must be admin");

        if (allowResign) {
            delegateToImplementation(abi.encodeWithSignature("_resignImplementation()"));
        }

        address oldImplementation = implementation;
        implementation = implementation_;

        delegateToImplementation(abi.encodeWithSignature("_becomeImplementation(bytes)", becomeImplementationData));

        emit NewImplementation(oldImplementation, implementation);
    }

    function proxyType() public pure returns (uint256 proxyTypeId) {
        return 2;
    }

    function _setAutoCompoundBlockThreshold(uint256 autoCompoundBlockThreshold_) override public returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_setAutoCompoundBlockThreshold(uint256)", autoCompoundBlockThreshold_));
        return abi.decode(data, (uint));
    }

    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
        return returnData;
    }

    function delegateToImplementation(bytes memory data) public returns (bytes memory) {
        return delegateTo(implementation, data);
    }

    function delegateToViewImplementation(bytes memory data) public view returns (bytes memory) {
        (bool success, bytes memory returnData) = address(this).staticcall(abi.encodeWithSignature("delegateToImplementation(bytes)", data));
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
        return abi.decode(returnData, (bytes));
    }

    receive() external payable {}
    fallback() external payable {
        require(msg.value == 0,"CErc20Delegator:fallback: cannot send value to fallback");

        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 { revert(free_mem_ptr, returndatasize()) }
            default { return(free_mem_ptr, returndatasize()) }
        }
    }

    function approveGlpRewardRouterWETHSpending() external {
      require(msg.sender == admin, "only admin can call approve");
      IERC20(WETH).approve(glpManager, type(uint256).max);
    }

}
