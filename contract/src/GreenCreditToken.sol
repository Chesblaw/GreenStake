// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title GreenCreditToken - Tokenized Carbon Credit
/// @notice Represents verified carbon offsets on-chain.
contract GreenCreditToken is ERC20, Ownable {
    struct CreditMetadata {
        string ipfsHash;      // Project verification data
        string projectId;     // Project identifier
        string certificateId; // Certification body reference
    }

    mapping(uint256 => CreditMetadata) public creditData;
    uint256 public nextTokenId;

    event CreditMinted(address indexed to, uint256 amount, string ipfsHash, string projectId, string certificateId);
    event CreditRetired(address indexed from, uint256 amount, string projectId);

    constructor(address initialOwner) ERC20("GreenStake Carbon Credit", "GSTK") Ownable(initialOwner) {}

    /// @notice Mint verified carbon credits
    function mint(
        address to,
        uint256 amount,
        string memory ipfsHash,
        string memory projectId,
        string memory certificateId
    ) external onlyOwner {
        _mint(to, amount);
        creditData[nextTokenId] = CreditMetadata(ipfsHash, projectId, certificateId);
        emit CreditMinted(to, amount, ipfsHash, projectId, certificateId);
        nextTokenId++;
    }

    /// @notice Burn credits to retire them from circulation
    function retire(uint256 amount, string memory projectId) external {
        _burn(msg.sender, amount);
        emit CreditRetired(msg.sender, amount, projectId);
    }
}
