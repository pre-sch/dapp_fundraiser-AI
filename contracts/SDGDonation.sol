// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol"; // Add this import
import "./SDGEventFactory.sol";
import "./SDGImpactNFT.sol";

contract SDGDonation is Ownable, ReentrancyGuard {
    using Strings for uint256; // Add this line
    SDGEventFactory public eventFactory;
    SDGImpactNFT public nftContract;

    mapping(address => mapping(uint8 => uint256)) public donorContributions;
    mapping(address => uint256) public totalDonations;

    event DonationSuccessful(
        address donor,
        uint256 eventId,
        uint8 sdg,
        uint256 amount,
        bool nftMinted
    );

    constructor(address _eventFactory, address _nftContract) 
        Ownable(msg.sender) 
    {
        eventFactory = SDGEventFactory(_eventFactory);
        nftContract = SDGImpactNFT(_nftContract);
    }

    function donate(uint256 eventId) external payable nonReentrant {
        SDGEventFactory.Event memory event_ = eventFactory.getEvent(eventId);
        
        // Simple input validation for beginners
        require(msg.value > 0, "Donation required");
        require(event_.isActive, "Event inactive");
        require(block.timestamp < event_.deadline, "Event ended");
        require(msg.value >= event_.minDonation, "Below minimum");
        require(msg.value <= event_.maxDonation, "Above maximum");

        // Track donations
        donorContributions[msg.sender][event_.sdgCategory] += msg.value;
        totalDonations[msg.sender] += msg.value;

        // Mint NFT if threshold met
        bool minted = false;
        if(msg.value >= event_.nftMintThreshold) {
            string memory uri = string(abi.encodePacked(
            "https://api.sdgfunder.com/nft/",
            Strings.toString(uint256(event_.sdgCategory)), // Convert to uint256 first
             "/",
            block.timestamp.toString()
        ));
        nftContract.safeMint(msg.sender, event_.sdgCategory, uri); // Now using 'uri'
        minted = true;
    }

        emit DonationSuccessful(
            msg.sender,
            eventId,
            event_.sdgCategory,
            msg.value,
            minted
        );
    }

    // Simple withdrawal for contract owner
    function withdrawFunds(address payable to) external onlyOwner nonReentrant {
        require(to != address(0), "Invalid address");
        to.transfer(address(this).balance);
    }
}