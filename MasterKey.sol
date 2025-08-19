// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Ownable.sol"; 

contract MasterKey is Ownable {
    event FundsDeposited(address indexed sender, uint256 value);
    event FundsWithdrawn(address indexed receiver, uint256 value);

    function deposit() external payable {
        require(msg.value > 0, "Vault: zero deposit");
        emit FundsDeposited(msg.sender, msg.value);
    }

    function withdraw(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Vault: zero recipient");
        require(amount <= address(this).balance, "Vault: insufficient balance");
        emit FundsWithdrawn(recipient, amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
