// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/GreenCreditToken.sol";

/**
 * @title GreenStakeDAO
 * @notice Community governance for approving carbon offset projects
 */
contract GreenStakeDAO is Ownable {
    struct Proposal {
        uint256 id;
        string projectId;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        mapping(address => bool) voted;
    }

    GreenCreditToken public governanceToken;
    uint256 public proposalCount;

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 indexed proposalId, string projectId);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId, bool approved);

    constructor(address _governanceToken, address _owner) Ownable(_owner) {
        governanceToken = GreenCreditToken(_governanceToken);
    }

    function createProposal(string memory projectId) external onlyOwner returns (uint256) {
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.id = proposalCount;
        p.projectId = projectId;

        emit ProposalCreated(proposalCount, projectId);
        return proposalCount;
    }

    function vote(uint256 proposalId, bool support) external {
        Proposal storage p = proposals[proposalId];
        require(!p.executed, "Proposal already executed");
        require(!p.voted[msg.sender], "Already voted");

        uint256 voterWeight = governanceToken.balanceOf(msg.sender);
        require(voterWeight > 0, "No voting power");

        if (support) {
            p.votesFor += voterWeight;
        } else {
            p.votesAgainst += voterWeight;
        }
        p.voted[msg.sender] = true;

        emit Voted(proposalId, msg.sender, support, voterWeight);
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(!p.executed, "Already executed");

        bool approved = p.votesFor > p.votesAgainst;
        p.executed = true;

        emit ProposalExecuted(proposalId, approved);
    }
}
