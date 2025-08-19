// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CustomToken is ERC20 {

    constructor(uint256 supply) ERC20("SabaleCoin", "SBL") {
        _mint(msg.sender, supply * 10 ** decimals());
    }
}
