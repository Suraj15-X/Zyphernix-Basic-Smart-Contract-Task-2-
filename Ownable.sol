// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract AccessControl {
    address private _admin;

    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    constructor() {
        _admin = msg.sender;
        emit AdminChanged(address(0), _admin);
    }

    function admin() public view returns (address) {
        return _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "AccessControl: caller is not admin");
        _;
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "AccessControl: new admin is the zero address");
        emit AdminChanged(_admin, newAdmin);
        _admin = newAdmin;
    }
}
