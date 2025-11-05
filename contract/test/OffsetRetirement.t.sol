// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GreenCreditToken.sol";
import "../src/OffsetRetirement.sol";

contract OffsetRetirementTest is Test {
    GreenCreditToken token;
    OffsetRetirement retirement;

    address owner = address(this);
    address company = address(0xBEEF);

    function setUp() public {
        token = new GreenCreditToken(owner);
        retirement = new OffsetRetirement(address(token), owner);

        token.mint(company, 100e18, "Qm123", "P1", "C1");

        // Company approves contract to spend tokens
        vm.startPrank(company);
        token.approve(address(retirement), type(uint256).max);
        vm.stopPrank();
    }

    function testRetirementRecord() public {
        vm.startPrank(company);
        retirement.retire(25e18, "P1");
        vm.stopPrank();

        OffsetRetirement.RetirementRecord[] memory recs = retirement.getUserRetirements(company);
        assertEq(recs.length, 1);
        assertEq(recs[0].amount, 25e18);
        assertEq(recs[0].account, company);
        assertEq(recs[0].projectId, "P1");
    }

    function testEmitEventOnRetire() public {
        vm.startPrank(company);
        vm.expectEmit(true, false, false, true);
        emit OffsetRetirement.TokensRetired(company, 10e18, "P2", block.timestamp);
        retirement.retire(10e18, "P2");
        vm.stopPrank();
    }

    function testCannotRetireZeroAmount() public {
        vm.startPrank(company);
        vm.expectRevert("Invalid amount");
        retirement.retire(0, "P1");
        vm.stopPrank();
    }

    function testCannotRetireWithoutProjectId() public {
        vm.startPrank(company);
        vm.expectRevert("Project ID required");
        retirement.retire(10e18, "");
        vm.stopPrank();
    }
}
