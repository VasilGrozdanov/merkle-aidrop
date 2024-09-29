//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {console2} from "forge-std/Test.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    address[] claimers;
    bytes32 private constant MESSAGE_TYPE_HASH =
        keccak256("AirdropClaim(address account,uint256 amount)");
    bytes32 private immutable i_root;
    IERC20 private immutable i_token;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    event Claim(address indexed account, uint256 amount);

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__InvalidSignature();
    error MerkleAirdrop__AlreadyClaimed();

    constructor(bytes32 merkleRoot, IERC20 token) EIP712("MerkleAirdrop", "1") {
        i_root = merkleRoot;
        i_token = token;
    }

    function claim(
        address acount,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_hasClaimed[acount]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        if (
            !_isValidSignature(acount, getMessageHash(acount, amount), v, r, s)
        ) {
            revert MerkleAirdrop__InvalidSignature();
        }
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(acount, amount)))
        );
        if (!MerkleProof.verify(merkleProof, i_root, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[acount] = true;
        emit Claim(acount, amount);
        i_token.safeTransfer(acount, amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_root;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_token;
    }

    function getMessageHash(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        bytes32 hashed = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    MESSAGE_TYPE_HASH,
                    AirdropClaim({account: account, amount: amount})
                )
            )
        );

        return hashed;
    }

    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
}
