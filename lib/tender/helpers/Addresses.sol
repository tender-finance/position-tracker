// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IERC20} from 'lib/interface/Tokens.sol';
import {ICToken} from 'lib/interface/CToken.sol';
import {IComptroller} from 'lib/interface/Comptroller.sol';
import {
  IRewardRouterV2,
  IStakedGlp,
  IRewardTracker,
  IGlpManager,
  IGmxVault,
  IRewardRouterV2
} from 'lib/interface/GMX.sol';

contract ERC20Addresses {
  IERC20 public
    wETH = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
  IERC20 public
    WBTC = IERC20(0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f);
  IERC20 public
    LINK = IERC20(0xf97f4df75117a78c1A5a0DBb814Af92458539FB4);
  IERC20 public
    UNI  = IERC20(0xFa7F8980b0f1E64A2062791cc3b0871572f1F7f0);
  IERC20 public
    USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
  IERC20 public
    USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
  IERC20 public
    DAI  = IERC20(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1);
  IERC20 public
    FRAX = IERC20(0x17FC002b466eEc40DaE837Fc4bE5c67993ddBd6F);
  IERC20 public
    GMX  = IERC20(0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a);
}

contract CompoundAddresses {
  ICToken public
    tETH   = ICToken(0x0706905b2b21574DEFcF00B5fc48068995FCdCdf);
  ICToken public
    tWBTC  = ICToken(0x0A2f8B6223EB7DE26c810932CCA488A4936cF391);
  ICToken public
    tLINK  = ICToken(0x87D06b55e122a0d0217d9a4f85E983AC3d7a1C35);
  ICToken public
    tUNI   = ICToken(0x8b44D3D286C64C8aAA5d445cFAbF7a6F4e2B3A71);
  ICToken public
    tUSDC  = ICToken(0x068485a0f964B4c3D395059a19A05a8741c48B4E);
  ICToken public
    tUSDT  = ICToken(0x4A5806A3c4fBB32F027240F80B18b26E40BF7E31);
  ICToken public
    tDAI   = ICToken(0xB287180147EF1A97cbfb07e2F1788B75df2f6299);
  ICToken public
    tFRAX  = ICToken(0x27846A0f11EDC3D59EA227bAeBdFa1330a69B9ab);
  ICToken public
    tGMX   = ICToken(0x20a6768F6AABF66B787985EC6CE0EBEa6D7Ad497);
  ICToken public
    tfsGLP = ICToken(0xFF2073D3810754D6da4783235c8647e11e43C943);

  IComptroller public
    unitroller = IComptroller(0xeed247Ba513A8D6f78BE9318399f5eD1a4808F8e);
}

contract GMXAddresses {
  IERC20 public glpToken
    = IERC20(0x4277f8F2c384827B5273592FF7CeBd9f2C1ac258);
  IGlpManager public glpManager
    = IGlpManager(0x3963FfC9dff443c2A94f21b129D429891E32ec18);
  IRewardTracker public fsGLP
    = IRewardTracker(0x1aDDD80E6039594eE970E5872D247bf0414C8903);
  IGmxVault public glpVault =
    IGmxVault(0x489ee077994B6658eAfA855C308275EAd8097C4A);
  IRewardRouterV2 public glpRouter =
    IRewardRouterV2(0xB95DB5B167D75e6d04227CfFFA61069348d271F5);
  IStakedGlp public stakedGlp =
    IStakedGlp(0x2F546AD4eDD93B956C8999Be404cdCAFde3E89AE);
}

contract Addresses is ERC20Addresses, CompoundAddresses, GMXAddresses {}
