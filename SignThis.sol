// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract TicketVerifier {
    mapping(address => bool) public verifiedGuests;
    address public organizer; 

    constructor(address _organizer) {
        organizer = _organizer;
    }

    function verifyEntry(address guest, bytes memory sig) external {
        require(!verifiedGuests[guest], "Guest already verified");

        bytes32 msgHash = keccak256(abi.encodePacked(guest));
        bytes32 ethMsgHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));

        address signer = extractSigner(ethMsgHash, sig);
        require(signer == organizer, "Unauthorized signature");

        verifiedGuests[guest] = true;
    }

    function extractSigner(bytes32 _ethMsgHash, bytes memory _sig) public pure returns(address) {
        require(_sig.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        return ecrecover(_ethMsgHash, v, r, s);
    }
}
