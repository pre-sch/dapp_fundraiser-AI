// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SDGImpactNFT is ERC721, Ownable {
    using Strings for uint256;
    
    mapping(uint256 => uint8) public tokenSDG;
    mapping(uint256 => string) private _tokenURIs;
    uint256 private _nextTokenId;

    constructor() ERC721("SDGImpactNFT", "SDGNFT") Ownable(msg.sender) {}

    event NFTMinted(address indexed to, uint256 tokenId, uint8 sdg);

    // Helper function to check token existence
    function _tokenExists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function safeMint(address to, uint8 sdg, string memory uri) 
        external 
        onlyOwner 
        returns (uint256) 
    {
        require(sdg >= 1 && sdg <= 17, "Invalid SDG ID");
        
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        tokenSDG[tokenId] = sdg;
        
        emit NFTMinted(to, tokenId, sdg);
        return tokenId;
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_tokenExists(tokenId), "Token doesn't exist"); // Using our helper
        require(bytes(_tokenURIs[tokenId]).length == 0, "URI already set");
        _tokenURIs[tokenId] = uri;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_tokenExists(tokenId), "Token doesn't exist"); // Using our helper
        return _tokenURIs[tokenId];
    }
}