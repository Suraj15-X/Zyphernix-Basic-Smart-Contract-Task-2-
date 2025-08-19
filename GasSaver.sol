// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract EfficientVote {
    struct Choice {
        string title;
        uint256 totalVotes;
    }

    Choice[] public choices;
    mapping(address => bool) public voted;

    constructor(string[] memory choiceNames) {
        for (uint256 i = 0; i < choiceNames.length; i++) {
            choices.push(Choice({
                title: choiceNames[i],
                totalVotes: 0
            }));
        }
    }

    function castVote(uint256 choiceIndex) external {
        require(!voted[msg.sender], "You already voted");
        voted[msg.sender] = true;
        Choice storage selected = choices[choiceIndex];
        selected.totalVotes += 1;
    }

    function topChoice() external view returns (string memory winningTitle, uint256 voteCount) {
        uint256 highest;
        uint256 length = choices.length; 

        for (uint256 i = 0; i < length; i++) {
            if (choices[i].totalVotes > highest) {
                highest = choices[i].totalVotes;
                winningTitle = choices[i].title;
                voteCount = highest;
            }
        }
    }
}
