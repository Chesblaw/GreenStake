# Overview

GreenStake is a tokenized carbon offset and ESG tracking platform. The smart contract layer handles:

This example project includes:

- Carbon credit token issuance (ERC-20 / SPL)
- Offset retirement (burning tokens)
- DAO governance for project validation
- Integration with Chainlink oracles for external verification

The contracts are designed for Polygon and Solana, with modular structure allowing easy expansion.
## Usage

```shell
greenstake/
├── contracts/
│   └── greenstake/               # Smart contract workspace
│       ├── src/
│       │   ├── GreenCreditToken.sol    # ERC-20 token contract
│       │   ├── OffsetRetirement.sol    # Token retirement logic
│       │   ├── GreenStakeDAO.sol       # DAO governance contract
│       │   └── OracleIntegration.sol   # Chainlink oracle adapter
│       ├── scripts/
│       │   ├── deploy.ts               # Deployment script
│       │   └── upgrade.ts              # Upgrade script for existing contracts
│       ├── test/
│       │   ├── token.test.ts
│       │   ├── retirement.test.ts
│       │   └── dao.test.ts
│       ├── hardhat.config.ts
│       ├── tsconfig.json
│       └── package.json
├── docs/
│   └── CONTRACTS.md                  # Detailed contract documentation
├── README.md
└── .gitignore
```

## Building Contracts

```shell
# Compile contracts
npx hardhat compile
# Run tests
npx hardhat test

```
