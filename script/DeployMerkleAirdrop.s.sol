// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagleToken} from "src/BagleToken.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public constant s_merkleRoot =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public constant AMOUNT_TO_SEND = 25e18 * 4;

    function run() external returns (MerkleAirdrop, BagleToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagleToken) {
        vm.startBroadcast();
        BagleToken token = new BagleToken();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(s_merkleRoot, token);
        token.mint(token.owner(), AMOUNT_TO_SEND);
        token.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        vm.stopBroadcast();

        return (merkleAirdrop, token);
    }
}
