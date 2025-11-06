// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/GreenCreditToken.sol";
import "../src/OracleIntegration.sol";

contract OracleIntegrationTest is Test {
    GreenCreditToken token;
    OracleIntegration oracle;
    address owner = address(this);
    address oracleOwner = address(0x1234);
    address company = address(0xBEEF);

function setUp() public {
    token = new GreenCreditToken(owner);

    // Mint initial credits before transferring ownership
    token.mint(company, 100e18, "QmInitial", "P1", "C1");

    // Deploy oracle and transfer ownership afterwards
    oracle = new OracleIntegration(address(token), oracleOwner);
    token.transferOwnership(address(oracle));
}


    function testCannotUpdateUnverifiedProject() public {
        vm.startPrank(oracleOwner);
        vm.expectRevert(bytes("Project not verified"));
        oracle.updateTokenMetadata(1, "P1");
        vm.stopPrank();
    }

function testVerifyAndUpdateMetadata() public {
    vm.startPrank(oracleOwner); // Must be the Oracle owner, not the test contract!

    // Mint through the Oracle
    oracle.mintCredit(company, 100e18, "QmInitial", "P1", "C1");

    // Verify project
    oracle.verifyProject("P1", "QmVerifiedHash");

    // Update metadata using verified hash
    oracle.updateTokenMetadata(0, "P1");

    vm.stopPrank();

    // Assertions...
    (string memory ipfs, , ) = token.creditData(0);
    assertEq(ipfs, "QmVerifiedHash");
}

}
