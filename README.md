## 🛠 Quick Start

This project is built using [Foundry](https://book.getfoundry.sh/), a blazing fast, portable, and modular toolkit for Ethereum application development written in Rust.

### Prerequisites
- Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`

### Build & Test
```bash
# Clone the repository
git clone [https://github.com/Kunram/multisig-vault-test.git](https://github.com/Kunram/multisig-vault-test.git)
cd multisig-vault-test

# Compile the smart contracts
forge build

# Run the test suite with detailed trace logs (-vvv)
forge test -vvv
