# NFT Marketplace Smart Contract

## Overview
This smart contract, **NFT-Marketplace**, is an advanced NFT-based contract featuring whitelisting and a non-custodial marketplace on the Stacks blockchain. Created by **Muritadhor Arowolo**, it allows minting, managing ownership, and trading of non-fungible tokens (NFTs). Users can buy, sell, and transfer NFTs, while a whitelist mechanism controls minting access. Additionally, the contract includes administrative functions for secure management.

## Features
- **NFT Minting**: Allows users to mint up to 10 NFTs per collection with whitelist management.
- **Non-Custodial Marketplace**: Provides a platform for listing, buying, and selling NFTs without third-party custody.
- **Whitelist Control**: Limits minting to approved users, with adjustable minting allowances per user.
- **Administrative Functions**: Adds or removes contract administrators and allows admins to manage the whitelist.

---

## Contract Structure

### Constants and Data Storage
- **NFT Definition**: Defines the `advance-nft` non-fungible token.
- **Price and Limits**:
  - `advance-nft-price`: The cost for each minted NFT (set at 10 STX).
  - `collection-limit`: Sets the maximum number of NFTs (10) in each collection.
  - `collection-root-url`: URL for NFT metadata storage on IPFS.
- **State Variables**:
  - `admins`: List of contract administrators.
  - `collection-index`: Current NFT count in the collection.
  - **Maps**:
    - `whitelist`: Tracks users approved for minting, with their available minting spots.
    - `marketplace`: Records listed NFTs with their price and owner.
    - `user-tokens`: Lists NFTs owned by each user (up to 10).

### Core Functions

#### SIP-009 Compliance
Implements essential functions per SIP-009 standards:
1. **get-last-token-id**: Returns the latest token ID minted.
2. **get-token-uri**: Provides the URI of NFT metadata based on the token ID.
3. **get-owner**: Retrieves the NFT owner by ID.
4. **transfer**: Allows the token owner to transfer an NFT to another address.

#### Marketplace Functions
1. **list-in-ustx**: Lists an NFT with a specified price.
2. **unlist-in-ustx**: Removes an NFT from the marketplace.
3. **buy-in-ustx**: Facilitates a purchase by transferring STX to the seller and transferring NFT ownership to the buyer.
4. **get-listing-in-ustx**: Retrieves marketplace data for a specific NFT.

#### Minting Functions
1. **mint-one**: Mints one NFT if the user is whitelisted and pays the minting fee.
2. **mint-two** & **mint-five**: Mints multiple NFTs in a single transaction for convenience.
3. **get-mints**: Displays the user's minted NFTs.
4. **track-token**: A helper function to keep track of user-owned tokens.

### Administrative Functions
1. **add-admin**: Allows an existing admin to add new admins to the contract.
2. **whitelist-user**: Adds a user to the whitelist with a specified number of minting spots.

---

## Error Handling
The contract provides clear error messages for cases like unauthorized access, insufficient whitelist spots, token minting cap, duplicate listings, and more. The `asserts!` statements enforce access control and state validation.

---

## Usage Instructions

### Minting
1. **Whitelist Approval**: Users must be whitelisted to mint tokens.
2. **Mint Token**: Call `mint-one`, `mint-two`, or `mint-five` with the necessary STX amount.

### Listing and Selling
1. **List an NFT**: Call `list-in-ustx` with the NFT ID and price.
2. **Unlist**: If a user wants to remove their NFT from the marketplace, they can call `unlist-in-ustx`.
3. **Buy an NFT**: Users can purchase listed NFTs by calling `buy-in-ustx`.

### Administration
1. **Add Admin**: Existing admins can add other admins.
2. **Whitelist User**: Admins can add users to the whitelist with a specified number of minting spots.

---

## Future Improvements
Potential upgrades could include more complex marketplace features, auction functionality, and dynamic pricing mechanisms for NFTs.

---

## Author
**Muritadhor Arowolo**
