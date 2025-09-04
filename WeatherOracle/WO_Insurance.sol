// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CropCover {
    AggregatorV3Interface public climateFeed;
    address public provider;
    uint256 public premiumFee;
    uint256 public compensation;
    int256 public rainLimit;

    struct Cover {
        address farmer;
        bool active;
        bool paidOut;
    }

    mapping(address => Cover) public covers;

    constructor(
        address _feedAddress,
        uint256 _premiumFee,
        uint256 _compensation,
        int256 _rainLimit
    ) {
        provider = msg.sender;
        climateFeed = AggregatorV3Interface(_feedAddress);
        premiumFee = _premiumFee;
        compensation = _compensation;
        rainLimit = _rainLimit;
    }

    function purchaseCover() external payable {
        require(msg.value == premiumFee, "Exact premium required");
        require(!covers[msg.sender].active, "Cover already exists");

        covers[msg.sender] = Cover(msg.sender, true, false);
    }

    function requestCompensation() external {
        Cover storage cover = covers[msg.sender];
        require(cover.active, "No active cover");
        require(!cover.paidOut, "Already settled");

        (, int256 rainfall, , , ) = climateFeed.latestRoundData();
        require(rainfall < rainLimit, "Rainfall adequate, no claim");

        cover.paidOut = true;
        payable(msg.sender).transfer(compensation);
    }

    function addFunds() external payable {}
}
