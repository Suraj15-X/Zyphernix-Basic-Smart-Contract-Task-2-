// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ModuleHub {
    struct PlayerProfile {
        string username;
        string avatarURI;
        mapping(bytes4 => address) modules;
        uint256 rewardPoints;
    }

    mapping(address => PlayerProfile) private playerProfiles;

    event ProfileCreated(address indexed user, string username, string avatarURI);
    event ModuleAttached(address indexed user, bytes4 indexed selector, address module);
    event ModuleDetached(address indexed user, bytes4 indexed selector);

    function createProfile(string calldata _username, string calldata _avatarURI) external {
        playerProfiles[msg.sender].username = _username;
        playerProfiles[msg.sender].avatarURI = _avatarURI;
        emit ProfileCreated(msg.sender, _username, _avatarURI);
    }

    function fetchProfile(address user) external view returns (string memory, string memory, uint256) {
        PlayerProfile storage p = playerProfiles[user];
        return (p.username, p.avatarURI, p.rewardPoints);
    }

    function attachModule(bytes4 _selector, address _moduleAddr) external {
        playerProfiles[msg.sender].modules[_selector] = _moduleAddr;
        emit ModuleAttached(msg.sender, _selector, _moduleAddr);
    }

    function detachModule(bytes4 _selector) external {
        delete playerProfiles[msg.sender].modules[_selector];
        emit ModuleDetached(msg.sender, _selector);
    }

    function moduleFor(address user, bytes4 selector) external view returns (address) {
        return playerProfiles[user].modules[selector];
    }

    function addRewards(uint256 points) external {
        playerProfiles[msg.sender].rewardPoints += points;
    }

    function getRewards(address user) external view returns (uint256) {
        return playerProfiles[user].rewardPoints;
    }

    function runModule(bytes4 _funcSelector, bytes calldata _data) external returns (bytes memory) {
        address module = playerProfiles[msg.sender].modules[_funcSelector];
        require(module != address(0), "Module not attached");

        (bool success, bytes memory result) = module.delegatecall(_data);
        require(success, "Module execution failed");
        return result;
    }
}
