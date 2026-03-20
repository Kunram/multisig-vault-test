# evm-multisig-vault

A gas-optimized, bare-bones Multi-Signature Wallet implementation for the Ethereum Virtual Machine (EVM). It utilizes Custom Errors for low gas consumption and strictly enforces state transitions through isolated modifiers.

## Architecture

- **M-of-N Threshold**: Requires a predefined `numConfirmationsRequired` quorum to execute `.call{}` payloads.
- **State Mutability Enforcement**: Modifiers (`notExecuted`, `notConfirmed`) isolate state transitions to prevent reentrancy and double-spending.
- **Gas Efficiency**: Relies exclusively on `Custom Errors` introduced in Solidity 0.8.4+ rather than string-based `require` statements.

## Repository Structure

- `src/`: Core EVM smart contract logic.
- `test/`: State machine and access control tests using Foundry.
- `script/`: Deployment automation scripts.

## Usage

Built and tested with [Foundry](https://book.getfoundry.sh/).

### Build
```bash
forge build
```

### Test
Executes the test suite with trace logs for reverted state transactions.
```bash
forge test -vvv
```
