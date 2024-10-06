// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagleToken} from "src/BagleToken.sol";
import {ClaimAirdrop} from "script/Interactions.s.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";

contract InteractionsTest is Test, ZkSyncChainChecker {
    MerkleAirdrop public merkleAirdrop;
    BagleToken public token;
    address constant GAS_PAYER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    address constant USER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 constant PRIVATE_KEY =
        77814517325470205911140941194401928579557062014761831930645393041380819009408;
    bytes32 PROOF_ONE =
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 public constant ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public constant AMOUNT_TO_SEND = 100e18;
    bytes private SIGNATURE =
        hex"4595e19ddb4c79e371961b98d3562c9bb9b0776276fa504adff4ee7da49d8767541a2311fc596b3db8893536860512f90a56b7426aad83ea1360cc47d257be371b";
    ClaimAirdrop claimer;

    modifier onlyAnvil() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    function setUp() external {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (merkleAirdrop, token) = deployer.run();
        } else {
            token = new BagleToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        }
        claimer = new ClaimAirdrop();
    }

    function testClaimAirdropOk() external onlyAnvil {
        claimer.claimAirdrop(address(merkleAirdrop), SIGNATURE);

        assertEq(token.balanceOf(USER), claimer.CLAIMING_AMOUNT());
    }

    function testSplitSignature() external view {
        bytes32 digest = merkleAirdrop.getMessageHash(
            USER,
            claimer.CLAIMING_AMOUNT()
        );

        (uint8 expectedV, bytes32 expectedR, bytes32 expectedS) = vm.sign(
            PRIVATE_KEY,
            digest
        );

        (uint8 actualV, bytes32 actualR, bytes32 actualS) = claimer
            .splitSignature(SIGNATURE);

        assertEq(expectedV, actualV);
        assertEq(expectedR, actualR);
        assertEq(expectedS, actualS);
    }
}
