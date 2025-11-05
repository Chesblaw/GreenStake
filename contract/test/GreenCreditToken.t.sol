// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GreenCreditToken.sol";

contract GreenCreditTokenTest is Test {
    GreenCreditToken token;
    address owner = address(this);
    address company = address(0xBEEF);

    function setUp() public {
        token = new GreenCreditToken(owner);
    }

    function testMint() public {
        token.mint(company, 100e18, "Qm123", "P1", "C1");

        assertEq(token.balanceOf(company), 100e18);

        (string memory ipfs, string memory projectId, string memory certId) = token.creditData(0);
        assertEq(ipfs, "Qm123");
        assertEq(projectId, "P1");
        assertEq(certId, "C1");
    }

    function testRetire() public {
        token.mint(company, 50e18, "QmABC", "P2", "C2");
        vm.startPrank(company);
        token.retire(20e18, "P2");
        vm.stopPrank();

        assertEq(token.balanceOf(company), 30e18);
    }

    function testOnlyOwnerCanMint() public {
vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0xBAD)));
        vm.prank(address(0xBAD));
        token.mint(company, 100e18, "Qm999", "P3", "C3");
    }
}
