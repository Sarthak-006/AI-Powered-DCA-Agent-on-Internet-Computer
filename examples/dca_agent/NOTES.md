# Development Notes

Just some random stuff I need to remember as I work on this.

## Setup Issues

- Had to use node v16.18.0 to get things working properly
- When dfx complains about canister IDs, delete .dfx and reinstall
- NEVER update webpack past 5.73.0 - breaks with newer versions

## TODO List

- [ ] Fix the portfolio calculation bug - totals aren't adding up right
- [ ] Add withdrawal functionality (blocked until we can test with real tokens)
- [ ] Make the UI mobile-friendly (looks terrible on my phone)
- [x] Update price feed to use real data (or at least better simulation)
- [ ] Write actual tests (lol)
- [ ] Fix that weird glitch when clicking "execute DCA" too fast

## Ideas to Explore Later

- Could use HTTP outcalls for real price data once that's supported
- Maybe add USDC support?
- Create a proper ML model for price prediction
- Auto-scheduling of DCA events (weekly buys etc)

## Meeting Notes (2/15)

- Everyone likes the UI design but wants more charts
- Sarah suggested we add a "history" view with graphs
- Need to discuss token integration with the ICP team
- Target: demo ready by end of month

## Useful Commands

```
# Run local replica with clean state
dfx start --clean --background

# Deploy locally
dfx deploy

# Deploy to mainnet
dfx deploy --network=ic

# Just rebuild the UI
npm run build
```

## Links & Resources

- [ICP Dev Docs](https://internetcomputer.org/docs/current/developer-docs/)
- [Our Figma Design](https://figma.com/file/example)
- [Chart.js Docs](https://www.chartjs.org/docs/latest/) (for when we add charts)
- [Trello Board](https://trello.com/b/example) 