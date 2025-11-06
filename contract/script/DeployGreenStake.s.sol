// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/GreenCreditToken.sol";
import "../src/OracleIntegration.sol";
import "../src/OffsetRetirement.sol";
import "../src/GreenStakeDAO.sol";

contract DeployGreenStake is Script {
    function run() external {
        vm.startBroadcast();

        address owner = msg.sender;

        GreenCreditToken token = new GreenCreditToken(owner);
        console.log("GreenCreditToken deployed at:", address(token));

        OracleIntegration oracle = new OracleIntegration(address(token), owner);
        console.log("OracleIntegration deployed at:", address(oracle));

        OffsetRetirement retirement = new OffsetRetirement(address(token), owner);
        console.log("OffsetRetirement deployed at:", address(retirement));

        GreenStakeDAO dao = new GreenStakeDAO(address(token), owner);
        console.log("GreenStakeDAO deployed at:", address(dao));

        vm.stopBroadcast();
    }
}
