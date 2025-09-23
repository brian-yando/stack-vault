# StackVault 🏦

## Next-Generation Bitcoin L2 Lending Protocol

[![Clarity Version](https://img.shields.io/badge/Clarity-v3-blue)](https://clarity-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen.svg)](#-testing)

StackVault represents the pinnacle of decentralized lending infrastructure on the Stacks blockchain, leveraging Bitcoin's security model to create a robust, capital-efficient lending ecosystem. Built for the sovereign Bitcoin economy.

## 🌟 Overview

StackVault is a sophisticated DeFi lending protocol that enables Bitcoin holders to unlock liquidity from their STX holdings while maintaining exposure to the Bitcoin ecosystem. The protocol implements advanced risk management algorithms, dynamic collateralization ratios, and automated liquidation mechanisms to ensure protocol stability and user capital protection.

### Key Features

- **🔒 Overcollateralized Lending**: Dynamic risk assessment with configurable collateral ratios
- **⚡ Automated Liquidation Engine**: Maintains protocol solvency through real-time monitoring
- **⛽ Gas-Optimized Operations**: Minimal transaction costs for all operations
- **📊 Real-time Monitoring**: Collateral ratio tracking and alerts
- **🏛️ Governance-Driven**: Parameter adjustments for market adaptability
- **🛡️ Bitcoin Security**: Inherits Bitcoin's security through Stacks' Proof-of-Transfer

## 🏗️ Architecture

### Security Model

The protocol inherits Bitcoin's security guarantees through Stacks' unique Proof-of-Transfer consensus mechanism, ensuring maximum security for user funds while enabling sophisticated DeFi primitives previously impossible on Bitcoin.

### Core Components

1. **Collateral Management**: Secure deposit and withdrawal of STX collateral
2. **Lending Engine**: Overcollateralized borrowing with dynamic ratios
3. **Liquidation System**: Automated position liquidation for protocol health
4. **Risk Management**: Real-time collateral ratio calculations and monitoring
5. **Governance**: Protocol parameter management and upgrades

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet/) v2.0+
- [Node.js](https://nodejs.org/) v18+
- [Git](https://git-scm.com/)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/stack-vault.git
cd stack-vault

# Install dependencies
npm install

# Check contract syntax
clarinet check

# Run tests
npm test
```

### Development Setup

```bash
# Start development environment
clarinet console

# Format contracts
clarinet fmt --in-place

# Run tests with coverage
npm run test:report

# Watch mode for continuous testing
npm run test:watch
```

## 📋 Usage

### Basic Operations

#### 1. Deposit Collateral

```clarity
;; Deposit all available STX as collateral
(contract-call? .stack-vault deposit-collateral)
```

#### 2. Borrow STX

```clarity
;; Borrow 1000 STX against collateral
(contract-call? .stack-vault borrow-stx u1000000000)
```

#### 3. Repay Loan

```clarity
;; Repay 500 STX
(contract-call? .stack-vault repay-loan u500000000)
```

#### 4. Withdraw Collateral

```clarity
;; Withdraw 2000 STX collateral
(contract-call? .stack-vault withdraw-collateral u2000000000)
```

### Read-Only Functions

#### Get User Portfolio

```clarity
;; Check user's lending position
(contract-call? .stack-vault get-user-portfolio 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

#### Protocol Analytics

```clarity
;; Get protocol statistics
(contract-call? .stack-vault get-protocol-analytics)
```

## 🔧 Configuration

### Risk Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| Minimum Collateral Ratio | 150% | 110% - 500% | Required overcollateralization |
| Liquidation Threshold | 130% | 110% - 150% | Liquidation trigger point |
| Protocol Fee | 1% | 0% - 10% | Platform fee rate |

### Governance Functions

Only the protocol owner can modify these parameters:

```clarity
;; Update minimum collateral ratio
(contract-call? .stack-vault update-minimum-collateral-ratio u200)

;; Update liquidation threshold
(contract-call? .stack-vault update-liquidation-threshold u135)

;; Update protocol fee
(contract-call? .stack-vault update-protocol-fee u2)
```

## 🧪 Testing

The protocol includes comprehensive test coverage for all core functionality:

```bash
# Run all tests
npm test

# Run with coverage report
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Categories

- **Unit Tests**: Individual function testing
- **Integration Tests**: End-to-end protocol workflows
- **Edge Cases**: Boundary conditions and error scenarios
- **Security Tests**: Access control and vulnerability checks

## 📊 Protocol Metrics

### Key Performance Indicators

- **Total Value Locked (TVL)**: Total STX deposited as collateral
- **Total Borrowed**: Aggregate borrowed amount
- **Utilization Rate**: Borrowed amount / Total deposits
- **Collateralization Ratio**: Average protocol health metric
- **Active Positions**: Number of active lending positions

### Analytics Dashboard

Query real-time protocol metrics:

```clarity
(contract-call? .stack-vault get-protocol-analytics)
```

Returns:

```json
{
  "total-value-locked": "uint",
  "total-borrowed-amount": "uint",
  "minimum-collateral-ratio": "uint",
  "liquidation-threshold": "uint",
  "protocol-fee-rate": "uint",
  "utilization-rate": "uint"
}
```

## 🛡️ Security

### Audit Status

- **Internal Security Review**: ✅ Completed
- **External Audit**: 🔄 Pending
- **Bug Bounty Program**: 📋 Planned

### Security Features

1. **Access Control**: Role-based permissions for governance functions
2. **Input Validation**: Comprehensive parameter checking
3. **Overflow Protection**: Safe arithmetic operations
4. **Reentrancy Guards**: Protection against recursive calls
5. **Emergency Pausing**: Circuit breakers for critical scenarios

### Known Limitations

- Protocol is currently in beta testing phase
- External price feeds not yet integrated
- Multi-asset collateral support pending

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

### Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Make your changes and add tests
4. Run the test suite: `npm test`
5. Format your code: `clarinet fmt --in-place`
6. Commit your changes: `git commit -am 'Add new feature'`
7. Push to the branch: `git push origin feature/new-feature`
8. Submit a pull request

### Code Standards

- Follow Clarity best practices and naming conventions
- Include comprehensive tests for all new functionality
- Document all public functions with clear comments
- Maintain gas efficiency in all operations

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
