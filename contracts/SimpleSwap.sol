// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ISimpleSwap } from "./interface/ISimpleSwap.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract SimpleSwap is ISimpleSwap, ERC20 {
    // Implement core logic here

    ERC20 public tokenA;
    ERC20 public tokenB;
    uint256 public kLast;
    uint256 public reserveA;
    uint256 public reserveB;

    constructor(address _tokenA, address _tokenB) ERC20("MyToken", "MTK") {
        require(_isContract(_tokenA), "SimpleSwap: TOKENA_IS_NOT_CONTRACT");
        require(_isContract(_tokenB), "SimpleSwap: TOKENB_IS_NOT_CONTRACT");
        require(_tokenA != _tokenB, "SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");
        // TODO: tokenA's address should be less than tokenB's address
        ERC20(_tokenA);
        ERC20(_tokenB);
    }

    // ref: https://ethereum.stackexchange.com/questions/15641/how-does-a-contract-find-out-if-another-address-is-a-contract
    function _isContract(address _addr) private view returns (bool isContract) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function _validToken(address _token) private view returns (bool isValid) {
        return _isContract(_token) && (address(tokenA) == _token || address(tokenB) == _token);
    }

    /// @notice Swap tokenIn for tokenOut with amountIn
    /// @param tokenIn The address of the token to swap from
    /// @param tokenOut The address of the token to swap to
    /// @param amountIn The amount of tokenIn to swap
    /// @return amountOut The amount of tokenOut received
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        // forces error, when tokenIn is not tokenA or tokenB
        require(_validToken(tokenIn), "SimpleSwap: INVALID_TOKEN_IN");
        // forces error, when tokenOut is not tokenA or tokenB
        require(_validToken(tokenOut), "SimpleSwap: INVALID_TOKEN_OUT");
        // forces error, when tokenIn is the same as tokenOut
        require(tokenIn != tokenOut, "SimpleSwap: IDENTICAL_ADDRESS");
        // forces error, when amountIn is zero
        require(amountIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        // forces error, when amountOut is zero
        require(amountOut > 0, "SimpleSwap: INSUFFICIENT_OUTPUT_AMOUNT");

        address sender = _msgSender();
        uint256 reserveTokenIn = ERC20(tokenIn).balanceOf(address(this));
        uint256 reserveTokenOut = ERC20(tokenOut).balanceOf(address(this));
        uint256 diffK = reserveTokenOut * (reserveTokenIn + amountIn) - kLast;
        uint256 amountOut = diffK / (reserveTokenIn + amountIn);

        ERC20(tokenIn).transferFrom(sender, address(this), amountIn);
        ERC20(tokenOut).transfer(sender, amountOut);

        // should be able to swap from tokenA to tokenB: update reserveA, reserveB
        reserveA = tokenA.balanceOf(address(this));
        reserveB = tokenB.balanceOf(address(this));

        emit Swap(sender, tokenIn, tokenOut, amountIn, amountOut);

        return amountOut;
    }

    /// @notice Add liquidity to the pool
    /// @param amountAIn The amount of tokenA to add
    /// @param amountBIn The amount of tokenB to add
    /// @return amountA The actually amount of tokenA added
    /// @return amountB The actually amount of tokenB added
    /// @return liquidity The amount of liquidity minted
    function addLiquidity(uint256 amountAIn, uint256 amountBIn) 
        external 
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        ) {}

    /// @notice Remove liquidity from the pool
    /// @param liquidity The amount of liquidity to remove
    /// @return amountA The amount of tokenA received
    /// @return amountB The amount of tokenB received
    function removeLiquidity(uint256 liquidity) external returns (uint256 amountA, uint256 amountB) {}

    /// @notice Get the reserves of the pool
    /// @return reserveA The reserve of tokenA
    /// @return reserveB The reserve of tokenB
    function getReserves() external view returns (uint256 reserveA, uint256 reserveB) {
        return (reserveA, reserveB);
    }

    /// @notice Get the address of tokenA
    /// @return tokenA The address of tokenA
    function getTokenA() external view returns (address tokenA) {
        return address(tokenA);
    }

    /// @notice Get the address of tokenB
    /// @return tokenB The address of tokenB
    function getTokenB() external view returns (address tokenB) {
        return address(tokenB);
    }
}
