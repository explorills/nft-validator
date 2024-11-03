# explorills_NftValidator Contract

Optimized bitmap-based validator contract for ERC721 NFT collection validation

## General Functionality
1. Validates ERC721 NFTs from the explorills collection using efficient bitmap storage
2. Processes large batches of NFTs (up to 300) in a single transaction
3. Maintains permanent validation status for NFTs regardless of ownership changes

## Main Functions
* `validateAllBlueMinerals`: Validates all unvalidated ERC721 NFTs owned by the caller
* `manualBatchValidate`: Executor Address only to validate specific NFT by IDs
* `manualBatchUnvalidate`: Executor Address only to unvalidate specific NFT by IDs
* `getGeneralInfo`: View total validated and unvalidated NFTs
* `getAddressInfo`: View validated and unvalidated NFTs for specific address

## Technical Features
* Bitmap-based storage for gas optimization
* Capability to process large batches
* Enhanced event emission with detailed validation data

### Each event includes:
* Operator address
* Number of NFTs affected
* List of affected NFT IDs

## Technical Specifications
* Solidity Version: ^0.8.0
* EVM Version: London
* Optimizer: Enabled (200 runs)
* Network: Flare

## Security Considerations
* No external contract dependencies except for NFT interface

## Contract Architecture
```
explorills_NftValidator
├── Storage
│   ├── validationBitmap (mapping)
│   ├── totalValidatedNFTs
│   ├── contractOwner
│   └── paused status
├── Main Functions
│   ├── validateAllBlueMinerals
│   ├── manualBatchValidate
│   └── manualBatchUnvalidate
└── View Functions
    ├── getGeneralInfo
    └── getAddressInfo
```

## License
BSD-3-Clause License

## Contact

- main: [explorills.com](https://explorills.com)
- mint: [mint.explorills.com](https://mint.explorills.com)
- contact: info@explorills.com
- security contact: info@explorills.ai

## Contract Address
- 0x0E3a65c21059361eBca4Ce5aCFFb21615d1f12F1
  
### Find at

- [Flarescan.com](https://flarescan.com/address/0x0E3a65c21059361eBca4Ce5aCFFb21615d1f12F1/contract/14/code?chainid=14)
- [Flare-explorer](https://flare-explorer.flare.network/address/0x0E3a65c21059361eBca4Ce5aCFFb21615d1f12F1?tab=contract_code)

---

- explorills community 2024
