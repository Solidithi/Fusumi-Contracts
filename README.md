# Aptos Move Smart Contract Project

This is an Aptos Move smart contract project with sample contracts and
comprehensive testing.

## Project Structure

```
├── Move.toml              # Package configuration
├── sources/               # Smart contract source files
│   ├── hello_world_example.move   # Simple greeting contract example
│   └── token_manager_example.move # Token management contract example
├── scripts/               # Deployment and interaction scripts
│   └── deploy_hello_world.move
├── tests/                 # Test files
│   └── integration_tests.move
└── README.md             # This file
```

## Prerequisites

1. Install Aptos CLI: https://aptos.dev/tools/aptos-cli/install-cli/
2. Install Move language server extension for VS Code (optional but recommended)

## Getting Started

### 1. Install Aptos CLI

```bash
# On Linux/macOS
curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3

# Verify installation
aptos --version
```

### 2. Initialize Aptos Configuration

```bash
# Initialize a new Aptos account
aptos init

# This will create a .aptos directory with your configuration
```

### 3. Build the Project

```bash
# Compile all Move modules
aptos move compile

# Build with verbose output
aptos move compile --verbose
```

### 4. Run Tests

```bash
# Run all tests
aptos move test

# Run specific test
aptos move test --filter test_hello_world_integration

# Run tests with verbose output
aptos move test --verbose
```

### 5. Deploy to Testnet

```bash
# Publish the package
aptos move publish

# Publish to a specific network
aptos move publish --network testnet
```

## Smart Contracts

### Hello World Contract

A simple contract that demonstrates:

- Resource storage and management
- Event emission
- View functions
- Entry functions for user interaction

**Key Functions:**

- `initialize_greeting()` - Initialize greeting for an account
- `update_greeting()` - Update the greeting message
- `get_greeting()` - View current greeting (view function)
- `get_counter()` - View update counter (view function)

### Token Manager Contract

A more advanced contract that demonstrates:

- Custom token creation using Aptos Coin framework
- Access control (owner-only functions)
- Error handling
- Complex state management

**Key Functions:**

- `initialize_token()` - Create a new token
- `mint_tokens()` - Mint tokens (owner only)
- `transfer()` - Transfer tokens between accounts
- `balance()` - Check token balance (view function)

## Interacting with Contracts

### Using Aptos CLI

```bash
# Call a function
aptos move run \
  --function-id <ACCOUNT_ADDRESS>::hello_world::initialize_greeting

# Call with arguments
aptos move run \
  --function-id <ACCOUNT_ADDRESS>::hello_world::update_greeting \
  --args string:"Hello, Aptos!"

# View function call
aptos move view \
  --function-id <ACCOUNT_ADDRESS>::hello_world::get_greeting \
  --args address:<ACCOUNT_ADDRESS>
```

### Using TypeScript SDK

```typescript
import { AptosClient, AptosAccount, FaucetClient } from "aptos";

const client = new AptosClient("https://fullnode.testnet.aptoslabs.com");
const faucet = new FaucetClient("https://faucet.testnet.aptoslabs.com", client);

// Call a function
const payload = {
	type: "entry_function_payload",
	function: "<ACCOUNT_ADDRESS>::hello_world::update_greeting",
	arguments: ["Hello from TypeScript!"],
	type_arguments: [],
};

await client.generateSignAndSubmitTransaction(account, payload);
```

## Development Tips

1. **Use `#[view]` for read-only functions** - These can be called without gas
   fees
2. **Handle errors properly** - Use `assert!` with meaningful error codes
3. **Write comprehensive tests** - Test both success and failure scenarios
4. **Use events for off-chain monitoring** - Emit events for important state
   changes
5. **Follow Move naming conventions** - Use snake_case for functions and
   variables

## Resources

- [Aptos Documentation](https://aptos.dev/)
- [Move Language Reference](https://move-language.github.io/move/)
- [Aptos Move Examples](https://github.com/aptos-labs/aptos-core/tree/main/aptos-move/move-examples)
- [Aptos TypeScript SDK](https://github.com/aptos-labs/aptos-ts-sdk)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for your changes
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details
