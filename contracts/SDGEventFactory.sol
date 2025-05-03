// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SDGEventFactory is Ownable {
    struct Event {
        address organizer;
        uint256 goal;
        uint256 deadline;
        string ipfsSDGMetadata;
        uint8 sdgCategory; // 1-17 for UN SDGs
        bool isActive;
        uint256 minDonation;
        uint256 maxDonation;
        uint256 nftMintThreshold;
    }

    Event[] public events;

    constructor() Ownable(msg.sender) {} // Simple owner initialization

    event EventCreated(uint256 eventId, address organizer, uint8 sdgCategory);

    function createEvent(
        uint256 _goal,
        uint256 _deadline,
        string memory _ipfsSDGMetadata,
        uint8 _sdgCategory,
        uint256 _minDonation,
        uint256 _maxDonation,
        uint256 _nftMintThreshold
    ) external {
        require(_sdgCategory >= 1 && _sdgCategory <= 17, "Invalid SDG");
        require(_deadline > block.timestamp + 5 minutes, "Deadline too soon");
        require(_minDonation <= _maxDonation, "Invalid donation range");

        uint256 eventId = events.length;
        events.push(Event({
            organizer: msg.sender,
            goal: _goal,
            deadline: _deadline,
            ipfsSDGMetadata: _ipfsSDGMetadata,
            sdgCategory: _sdgCategory,
            isActive: true,
            minDonation: _minDonation,
            maxDonation: _maxDonation,
            nftMintThreshold: _nftMintThreshold
        }));

        emit EventCreated(eventId, msg.sender, _sdgCategory);
    }

    function toggleEventActive(uint256 eventId, bool isActive) external {
        require(msg.sender == events[eventId].organizer || msg.sender == owner(), "Not authorized");
        events[eventId].isActive = isActive;
    }

    function getEvent(uint256 eventId) external view returns (Event memory) {
    return events[eventId];
}
}