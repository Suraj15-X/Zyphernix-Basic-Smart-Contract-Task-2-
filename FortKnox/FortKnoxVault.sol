// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SilverVault is ReentrancyGuard {
    IERC20 public silverToken;
    mapping(address => uint256) public userBalances;

    constructor(address _silverToken) {
        silverToken = IERC20(_silverToken);
    }

    function depositTokens(uint256 amount) external {
        require(amount > 0, "Deposit must be greater than zero");
        require(silverToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        userBalances[msg.sender] += amount;
    }

    function withdrawTokens(uint256 amount) external nonReentrant {
        require(amount > 0, "Withdrawal must be greater than zero");
        require(userBalances[msg.sender] >= amount, "Not enough balance");

        userBalances[msg.sender] -= amount;
        require(silverToken.transfer(msg.sender, amount), "Transfer failed");
    }

    function checkBalance() external view returns (uint256) {
        return userBalances[msg.sender];
    }
}
