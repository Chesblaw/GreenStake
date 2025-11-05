// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/GreenCreditToken.sol";
import "../src/GreenStakeDAO.sol";

contract GreenStakeDAOTest is Test {
    GreenCreditToken token;
    GreenStakeDAO dao;

    address owner = address(this);
    address voter1 = address(0xBEEF);
    address voter2 = address(0xCAFE);

    function setUp() public {
        token = new GreenCreditToken(owner);
        dao = new GreenStakeDAO(address(token), owner);

        token.mint(voter1, 100e18, "Qm1", "P1", "C1");
        token.mint(voter2, 50e18, "Qm2", "P2", "C2");
    }

    function testProposalLifecycle() public {
        uint256 propId = dao.createProposal("Project1");
        assertEq(propId, 1);

        // Voting
        vm.prank(voter1);
        dao.vote(propId, true);

        vm.prank(voter2);
        dao.vote(propId, false);

        dao.executeProposal(propId);
        // votesFor = 100, votesAgainst = 50 => approved
    }

    function testCannotDoubleVote() public {
        uint256 propId = dao.createProposal("Project2");
        vm.prank(voter1);
        dao.vote(propId, true);

        vm.prank(voter1);
        vm.expectRevert("Already voted");
        dao.vote(propId, false);
    }

    function testCannotVoteWithoutTokens() public {
        uint256 propId = dao.createProposal("Project3");
        address noToken = address(0x1234);
        vm.prank(noToken);
        vm.expectRevert("No voting power");
        dao.vote(propId, true);
    }
}
