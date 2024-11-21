# Prediction Markets

This project implements a prediction markets system using Clarity smart contracts and the Clarinet development framework. The application includes the following components:

1. Event Outcome Betting
2. Oracle Integration for Real-World Data
3. Market Resolution Mechanisms

## Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet)
- [Node.js](https://nodejs.org/)

## Setup

1. Clone the repository:

git clone [https://github.com/yourusername/prediction-markets.git](https://github.com/yourusername/prediction-markets.git)
cd prediction-markets

```plaintext

2. Install dependencies:
```

npm install

```plaintext

3. Run tests:
```

clarinet test

```plaintext

## Contracts

### Event Betting

The `event-betting` contract manages the creation of prediction markets and placing bets:
- Create new prediction markets
- Place bets on market outcomes
- Retrieve market and bet information

### Oracle Integration

The `oracle-integration` contract handles the integration of real-world data through oracles:
- Add and remove authorized oracles
- Report outcomes for markets
- Retrieve oracle reports

### Market Resolution

The `market-resolution` contract manages the resolution of markets and distribution of winnings:
- Resolve markets based on oracle reports
- Allow winners to claim their winnings
- Handle the payout mechanism

## Testing

Each contract has its own test file in the `tests` directory. You can run all tests using the `clarinet test` command.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
```
