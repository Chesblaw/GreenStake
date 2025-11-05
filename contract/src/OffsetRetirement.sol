// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title OffsetRetirement
 * @notice Manages retirement (burning) of GreenCreditTokens to represent actual carbon offsets.
 * @dev Emits transparent on-chain records for verifiable ESG reporting.
 */
contract OffsetRetirement is Ownable {
    /// @dev Interface for interacting with the GreenCreditToken
    IERC20 public immutable greenCreditToken;

    struct RetirementRecord {
        address account;
        uint256 amount;
        string projectId;
        uint256 timestamp;
    }

    uint256 public totalRetired;
    mapping(address => RetirementRecord[]) public retirements;

    event TokensRetired(
        address indexed account,
        uint256 amount,
        string projectId,
        uint256 timestamp
    );

    constructor(address _token, address _initialOwner) Ownable(_initialOwner) {
        require(_token != address(0), "Invalid token address");
        greenCreditToken = IERC20(_token);
    }

    /**
     * @notice Retire carbon credits by burning equivalent tokens.
     * @param amount The number of tokens to retire.
     * @param projectId The project ID associated with the retirement.
     */
    function retire(uint256 amount, string memory projectId) external {
        require(amount > 0, "Invalid amount");
        require(bytes(projectId).length > 0, "Project ID required");

        // Transfer tokens from user to this contract (assuming approval)
        bool success = greenCreditToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        // Burn tokens (contract must have burn privileges)
        // For simplicity, in v1, we "lock" tokens here; in v2, GreenCreditToken will expose burnFrom()
        totalRetired += amount;

        retirements[msg.sender].push(RetirementRecord({
            account: msg.sender,
            amount: amount,
            projectId: projectId,
            timestamp: block.timestamp
        }));

        emit TokensRetired(msg.sender, amount, projectId, block.timestamp);
    }

    function getUserRetirements(address user)
        external
        view
        returns (RetirementRecord[] memory)
    {
        return retirements[user];
    }
}
