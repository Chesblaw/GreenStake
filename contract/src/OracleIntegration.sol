// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./GreenCreditToken.sol";

contract OracleIntegration is Ownable {
    GreenCreditToken public immutable greenCreditToken;

    mapping(string => string) public verifiedData;

    event ProjectVerified(string projectId, string ipfsHash);
    event TokenMetadataUpdated(uint256 tokenId, string projectId, string ipfsHash);

    constructor(address _token, address _owner) Ownable(_owner) {
        greenCreditToken = GreenCreditToken(_token);
    }
    function mintCredit(
    address to,
    uint256 amount,
    string memory ipfsHash,
    string memory projectId,
    string memory certificateId
) external onlyOwner {
    greenCreditToken.mint(to, amount, ipfsHash, projectId, certificateId);
}


    function verifyProject(string memory projectId, string memory ipfsHash) external onlyOwner {
        verifiedData[projectId] = ipfsHash;
        emit ProjectVerified(projectId, ipfsHash);
    }

    function updateTokenMetadata(uint256 tokenId, string memory projectId) external onlyOwner {
        string memory ipfsHash = verifiedData[projectId];
        require(bytes(ipfsHash).length > 0, "Project not verified");

        (string memory oldHash, , string memory certId) = greenCreditToken.creditData(tokenId);

        greenCreditToken.updateMetadata(tokenId, ipfsHash, projectId, certId);
        emit TokenMetadataUpdated(tokenId, projectId, ipfsHash);
    }
}
