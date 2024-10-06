//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagleToken} from "src/BagleToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop public merkleAirdrop;
    BagleToken public token;
    bytes32 public constant ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public constant AMOUNT_TO_CLAIM = 25e18;
    uint256 public constant AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 PROOF_ONE =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 PROOF_TWO =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [PROOF_ONE, PROOF_TWO];
    address public gasPayer;
    address public user;
    uint256 public privateKey;

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
        (user, privateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testInitialization() external view {
        assertEq(address(token), address(merkleAirdrop.getAirdropToken()));
        assertEq(ROOT, merkleAirdrop.getMerkleRoot());
    }

    function testUsersCanClaim() external {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = merkleAirdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        vm.prank(gasPayer);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingBalance = token.balanceOf(user);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }

    function testGetMessageHash() external view {
        bytes32 expectedDigest = 0x5b73bb35df5892cb2680ef6ece469a4db8e2df8011202f90bc682ed409494f4a;
        bytes32 actualDigest = merkleAirdrop.getMessageHash(
            user,
            AMOUNT_TO_CLAIM
        );

        assertEq(expectedDigest, actualDigest);
    }
}
