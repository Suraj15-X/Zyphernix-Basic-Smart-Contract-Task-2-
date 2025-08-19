// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface ILocker {
    function saveSecret(string calldata secret) external;
    function revealSecret() external view returns (string memory);
    function changeOwner(address newAdmin) external;
    function admin() external view returns (address);
}

contract SimpleLocker is ILocker {
    address private _admin;
    string private _note;

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Not authorized!");
        _;
    }

    constructor(address initialAdmin) {
        _admin = initialAdmin;
    }

    function saveSecret(string calldata secretIn) external onlyAdmin {
        _note = secretIn;
    }

    function revealSecret() external view override returns (string memory) {
        return _note;
    }

    function changeOwner(address newAdmin) external onlyAdmin {
        _admin = newAdmin;
    }

    function admin() external view returns (address) {
        return _admin;
    }
}

contract TimedLocker is ILocker {
    address private _admin;
    string private _note;
    uint256 public releaseTime;

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Not authorized!");
        _;
    }

    modifier unlocked() {
        require(block.timestamp >= releaseTime, "Still locked!");
        _;
    }

    constructor(address initialAdmin, uint256 _releaseTime) {
        _admin = initialAdmin;
        releaseTime = _releaseTime;
    }

    function saveSecret(string calldata secretIn) external onlyAdmin {
        _note = secretIn;
    }

    function revealSecret() external view override unlocked returns (string memory) {
        return _note;
    }

    function changeOwner(address newAdmin) external onlyAdmin {
        _admin = newAdmin;
    }

    function admin() external view returns (address) {
        return _admin;
    }
}

contract AdvancedLocker is ILocker {
    address private _admin;
    string[] private notes;
    mapping(address => bool) public allowed;

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Not authorized!");
        _;
    }

    modifier onlyAllowed() {
        require(msg.sender == _admin || allowed[msg.sender], "Access denied!");
        _;
    }

    constructor(address initialAdmin) {
        _admin = initialAdmin;
    }

    function saveSecret(string calldata secretIn) external onlyAdmin {
        notes.push(secretIn);
    }

    function revealSecret() external view override onlyAllowed returns (string memory) {
        require(notes.length > 0, "Nothing stored yet");
        return notes[notes.length - 1];
    }

    function revealAll() external view onlyAllowed returns (string[] memory) {
        return notes;
    }

    function authorize(address user) external onlyAdmin {
        allowed[user] = true;
    }

    function revoke(address user) external onlyAdmin {
        allowed[user] = false;
    }

    function changeOwner(address newAdmin) external onlyAdmin {
        _admin = newAdmin;
    }

    function admin() external view returns (address) {
        return _admin;
    }
}

contract LockerFactory {
    ILocker[] public lockers;

    function newSimpleLocker() external returns (address) {
        SimpleLocker locker = new SimpleLocker(msg.sender);
        lockers.push(locker);
        return address(locker);
    }

    function newTimedLocker(uint256 _releaseTime) external returns (address) {
        TimedLocker locker = new TimedLocker(msg.sender, _releaseTime);
        lockers.push(locker);
        return address(locker);
    }

    function newAdvancedLocker() external returns (address) {
        AdvancedLocker locker = new AdvancedLocker(msg.sender);
        lockers.push(locker);
        return address(locker);
    }

    function totalLockers() external view returns (uint256) {
        return lockers.length;
    }

    function getLocker(uint256 index) external view returns (address) {
        return address(lockers[index]);
    }
}
