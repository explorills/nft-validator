// SPDX-License-Identifier: BSD-3-Clause

// Pragma Directive
pragma solidity ^0.8.0;

// Interfaces
interface IValidatorNFT {
    function balanceOf(address owner) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

/**
 * ORIGINAL AUTHOR INFORMATION:
 * 
 * @author explorills community 2024
 * @custom:web https://explorills.com
 * @custom:contact info@explorills.com
 * @custom:security-contact info@explorills.ai
 * @custom:repository https://github.com/explorills/nft-validator
 * @title ERC721 NFT Validator Contract
 * @dev Optimized bitmap-based batch validator for ERC721 NFT collection
 * 
 * Contract redistribution or modification:
 * 
 * 1. Any names or terms related to "explorills," "Minerals," or their variations, cannot be used in any modified version's contract names, variables, or promotional materials without permission.
 * 2. The original author information (see above) must remain intact in all versions.
 * 3. In case of redistribution/modification, new author details must be added in the section below:
 * 
 * REDISTRIBUTED/MODIFIED BY:
 * 
 * /// @custom:redistributed-by <name or entity>
 * /// @custom:website <website of the redistributor>
 * /// @custom:contact <contact email or info of the redistributor>
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted under the 3-Clause BSD License. 
 * This license allows for broad usage and modification, provided the original copyright notice and disclaimer are retained.
 * The software is provided "as-is," without any warranties, and the original authors are not liable for any issues arising from its use.
 */

/// @author explorills community 2024
/// @custom:web https://explorills.com
/// @custom:contact info@explorills.com
/// @custom:security-contact info@explorills.ai
/// @custom:repository https://github.com/explorills/nft-validator
contract explorills_NftValidator {
    IValidatorNFT public nftContract;
    mapping(uint256 => uint256) private validationBitmap;
    uint256 public totalValidatedNFTs;
    address public contractOwner;
    bool public paused;
    
    
    event ValidationProcessed(address indexed validator, uint256 quantity, uint256[] validatedIds);
    
    constructor(address _nftContractAddress) {
        nftContract = IValidatorNFT(_nftContractAddress);
        contractOwner = msg.sender;
        paused = true;
    }
    
    // modifiers
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only Executor Address Can Call This Function");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

   // functions
    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function validateAllBlueMinerals() external whenNotPaused {
        uint256 balance = nftContract.balanceOf(msg.sender);
        require(balance > 0, "No NFTs to validate");
        
        uint256 validatedInThisCall = 0;
        uint256[] memory tempTokenIds = new uint256[](balance);
        uint256 tempCount = 0;
        
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = nftContract.tokenOfOwnerByIndex(msg.sender, i);
            if (!isValidated(tokenId)) {
                tempTokenIds[tempCount] = tokenId;
                tempCount++;
            }
        }
        
        require(tempCount > 0, "No unvalidated NFTs found");
        
        uint256 currentSlot = type(uint256).max;
        uint256 slotValue = 0;
        
        for (uint256 i = 0; i < tempCount; i++) {
            uint256 tokenId = tempTokenIds[i];
            uint256 slot = tokenId / 256;
            uint256 position = tokenId % 256;
            
            if (currentSlot != slot && currentSlot != type(uint256).max) {
                validationBitmap[currentSlot] |= slotValue;
                slotValue = 0;
            }
            
            currentSlot = slot;
            slotValue |= (1 << position);
            validatedInThisCall++;
        }
        
        if (slotValue != 0) {
            validationBitmap[currentSlot] |= slotValue;
        }
        
        totalValidatedNFTs += validatedInThisCall;

        uint256[] memory validatedIds = new uint256[](validatedInThisCall);
        for (uint256 i = 0; i < validatedInThisCall; i++) {
            validatedIds[i] = tempTokenIds[i];
        }
        
        emit ValidationProcessed(msg.sender, validatedInThisCall, validatedIds);
    }

    function _setValidated(uint256 tokenId) private {
        uint256 slot = tokenId / 256;
        uint256 position = tokenId % 256;
        if ((validationBitmap[slot] & (1 << position)) == 0) {
            validationBitmap[slot] |= (1 << position);
            totalValidatedNFTs++;
        }
    }

    function isValidated(uint256 tokenId) public view returns (bool) {
        uint256 slot = tokenId / 256;
        uint256 position = tokenId % 256;
        return (validationBitmap[slot] & (1 << position)) != 0;
    }

    function manualBatchValidate(uint256[] calldata tokenIds) external onlyOwner whenNotPaused {
        require(tokenIds.length > 0, "Empty array provided");
        
        uint256 validatedCount = 0;
        uint256 currentSlot = type(uint256).max;
        uint256 slotValue = 0;
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (!isValidated(tokenId)) {
                uint256 slot = tokenId / 256;
                uint256 position = tokenId % 256;
                
                if (currentSlot != slot && currentSlot != type(uint256).max) {
                    validationBitmap[currentSlot] |= slotValue;
                    slotValue = 0;
                }
                
                currentSlot = slot;
                slotValue |= (1 << position);
                validatedCount++;
            }
        }
        
        if (slotValue != 0) {
            validationBitmap[currentSlot] |= slotValue;
        }
        
        if (validatedCount > 0) {
            totalValidatedNFTs += validatedCount;
            emit ValidationProcessed(msg.sender, validatedCount, tokenIds);
        }
    }

    function manualBatchUnvalidate(uint256[] calldata tokenIds) external onlyOwner whenNotPaused {
        require(tokenIds.length > 0, "Empty array provided");
        
        uint256 unvalidatedCount = 0;
        uint256 currentSlot = type(uint256).max;
        uint256 slotValue = 0;
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (isValidated(tokenId)) {
                uint256 slot = tokenId / 256;
                uint256 position = tokenId % 256;
                
                if (currentSlot != slot && currentSlot != type(uint256).max) {
                    validationBitmap[currentSlot] &= ~slotValue;
                    slotValue = 0;
                }
                
                currentSlot = slot;
                slotValue |= (1 << position);
                unvalidatedCount++;
            }
        }
        
        if (slotValue != 0) {
            validationBitmap[currentSlot] &= ~slotValue;
        }
        
        if (unvalidatedCount > 0) {
            totalValidatedNFTs -= unvalidatedCount;
        }
    }

    function getGeneralInfo() public view returns (uint256 totalValidated, uint256 totalUnvalidated) {
        totalValidated = totalValidatedNFTs;
        uint256 totalSupply = nftContract.totalSupply();
        return (totalValidated, totalSupply - totalValidated);
    }

    function getAddressInfo(address owner) public view returns (uint256 validated, uint256 unvalidated) {
        uint256 balance = nftContract.balanceOf(owner);
        
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = nftContract.tokenOfOwnerByIndex(owner, i);
            if (isValidated(tokenId)) {
                validated++;
            } else {
                unvalidated++;
            }
        }
        
        return (validated, unvalidated);
    }

    function updateNFTContractAddress(address _newAddress) public onlyOwner {
        nftContract = IValidatorNFT(_newAddress);
    }
}
