# 🤖 AI-Powered DCA Agent on Internet Computer

> Autonomous, onchain investing powered by AI and secured by the Internet Computer

![Status](https://img.shields.io/badge/Status-MVP-yellow)
![Version](https://img.shields.io/badge/Version-0.1.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## What is this?

This is a proof-of-concept DCA (Dollar-Cost Averaging) agent that runs entirely on the Internet Computer blockchain. It's autonomous, onchain, and uses rule-based AI logic to make investment decisions.

The agent accepts ICP deposits, monitors price feeds (simulated in this MVP), and makes AI-driven decisions on when to execute trades across multiple assets. All activity is transparently recorded on the blockchain.


## ✨ Features

- 💰 **Deposit Management**: Accept and track user deposits in ICP
- 🧠 **AI-Powered Decisions**: Rule-based logic decides when to BUY or HOLD
- ⛓️ **Cross-Chain Simulation**: Shows how ICP can bridge to other chains via Chain Fusion
- 📊 **Portfolio Tracking**: Monitor your assets across chains
- 📝 **Transparent Logging**: All activity recorded on-chain for auditability

## 🏗️ Architecture

```
┌─────────────────┐     ┌──────────────────┐
│   Frontend UI   │─────▶   DCA Canister   │
└─────────────────┘     └──────────────────┘
                               │  ▲
                               │  │
                               ▼  │
                        ┌──────────────────┐
                        │  Price Oracles   │
                        │  (Simulated)     │
                        └──────────────────┘
```

- **Backend**: Motoko canister that handles deposits, DCA logic, and simulated trades.
- **Frontend**: Simple UI to interact with the canister, built with vanilla JS + Bootstrap.

## 🛠️ Tech Stack

- **Language**: [Motoko](https://internetcomputer.org/docs/current/developer-docs/build/cdks/motoko-dfinity/motoko/)
- **Platform**: [Internet Computer](https://internetcomputer.org/)
- **Frontend**: HTML, JavaScript, Bootstrap
- **Development Tools**: DFX SDK

## 🚀 Getting Started

### Prerequisites

- [DFINITY SDK (dfx)](https://sdk.dfinity.org/docs/quickstart/local-quickstart.html) version 0.26.0 or later
- Node.js 20 or later
- npm 8 or later

### Quick Start

1. Clone the repo and navigate to the project directory
```bash
git clone https://github.com/Sarthak-006/AI-Powered-DCA-Agent-on-Internet-Computer
cd examples/dca_agent
```

2. Install dependencies
```bash
npm install
```

3. Start a local Internet Computer replica
```bash
dfx start --clean --background
```

4. Deploy the canisters
```bash
dfx deploy
```

5. Open the app in your browser
```bash
npm start
```

## 🧪 Usage

1. **Deposit ICP**: Enter an amount and click "Deposit" (this is simulated in the MVP)
2. **Execute DCA**: Select your target asset, enter an amount, and execute the DCA strategy
3. **View Results**: Check your portfolio and transaction history to see the results

## 🗺️ Roadmap

- [x] MVP with simulated price feeds
- [x] Basic rule-based AI logic
- [x] User deposit and DCA execution
- [ ] Real-time price oracles via HTTP outcalls
- [ ] Improved AI models using ML algorithms
- [ ] Actual token transfers via ICRC-1
- [ ] Chain Fusion integration when available
- [ ] Automated scheduling of DCA strategies

## 🐛 Known Issues & Limitations

- Price data is simulated (not using real oracles yet)
- Trades are simulated (not actually executing on DEXes)
- No persistence across canister upgrades (will be added in v0.2)
- No withdrawal functionality yet (coming soon)

## 🤝 Contributing

Contributions welcome! Feel free to:

1. Fork the repo
2. Create a feature branch (`git checkout -b awesome-feature`)
3. Commit your changes (`git commit -am 'Add awesome feature'`)
4. Push to the branch (`git push origin awesome-feature`)
5. Open a Pull Request

## 📄 License

This project is MIT licensed - see the [LICENSE](../../LICENSE) file for details.

---

*This project is a demo and should not be used for real financial transactions yet. No real tokens are being transferred.*
