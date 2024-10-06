# ERC20 Token Airdrop Project 🌐💸

The airdrop is designed to ensure secure and efficient distribution of tokens to whitelisted recipients. The project also includes scripts for generating the whitelist and Merkle proofs for the airdrop. 


## 🚀 Features

- **ERC20 Token**: A fully functional ERC20 token, deployed and ready for distribution.
- **Merkle Airdrop**: Efficient token distribution using Merkle proofs.
- **Signature-based Claims**: Allows someone else to claim tokens on your behalf using ECDSA signatures (`v`, `r`, `s` values).
  
## Smart Contracts 📜
### ERC20 Token
- The standard ERC20 contract has all basic functionallity, provided in openzeppelin's ERC20 standard and is mintable only by the owner (deployer) of the token.

### MerkleAirdrop Contract
- **Merkle root setup**: A Merkle root is used to verify the recipients in the airdrop.
- **Claiming with proofs**: Users can claim tokens by submitting a Merkle proof.
- **Claiming by proxy**: Users can claim tokens for others using ECDSA signatures (v, r, s).

## Scripts 🛠️
### `GenerateInput.s.sol` 
This script creates the initial whitelist of recipients for the airdrop. The addresses and their corresponding allocations are generated based on your specifications.

### `MakeMerkle.s.sol`
This script generates the Merkle tree and the corresponding proofs, which will be used in the airdrop. It outputs the Merkle root and proofs required for each recipient to claim their tokens.

## How To Use 💻
1. **Token Deployment**: Deploy the ERC20 token contract.
2. **Whitelist Generation**: Run `GenerateInput.s.sol` to create the list of airdrop recipients.
3. **Merkle Tree Creation**: Run `MakeMerkle.s.sol` to generate the Merkle root and proofs.
4. **Claiming Tokens**: Recipients can claim their tokens by submitting Merkle proofs to the `MerkleAirdrop` contract. Alternatively, a trusted third party can claim the tokens on their behalf using signatures (v, r, s).

## License 📜
This project is licensed under the MIT License. 

Feel free to modify this project for your airdrop needs! 🎉


## ⬇️ Installation

### Clone the repository:
```bash
git clone https://github.com/VasilGrozdanov/merkle-aidrop.git
```

## 🛠️ Usage

### 🔨 Build
Use the [Makefile](https://github.com/VasilGrozdanov/merkle-aidrop/blob/main/Makefile) commands **(📝 note: Make sure you have GNU Make installed and add the necessary environment variables in a `.env` file)**, or alternatively foundry commands:
```shell
$ forge build
```

### 🧪 Test

```shell
$ forge test
```

### 🎨 Format

```shell
$ forge fmt
```

### ⛽ Gas Snapshots

```shell
$ forge snapshot
```

### 🔧 Anvil

```shell
$ anvil
```

### 🚀 Deploy

```shell
$ forge script script/DeployMerkleAirdrop.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```
> ⚠️ **Warning: Using your private key on a chain associated with real money must be avoided!**

 OR
```shell
$ forge script script/DeployMerkleAirdrop.s.sol --rpc-url <your_rpc_url> --account <your_account> --broadcast
```
> 📝 **Note: Using your --account requires adding wallet first, which is more secure than the plain text private key!**
```Bash
cast wallet import --interactive <name_your_wallet>
```
### 🛠️ Cast

```shell
$ cast <subcommand>
```

### ❓ Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
