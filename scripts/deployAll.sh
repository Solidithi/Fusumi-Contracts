#!/bin/bash

# Set your account address and private key file
ACCOUNT_ADDRESS="0x77f85a9b7343634d922850e47c1a34c9c529308ab8b1f1a850803149d95235c0"
PRIVATE_KEY_FILE="./.aptos/config.yaml" # Not needed if using --profile default

# Publish all modules
aptos move publish \
  --package-dir /home/tron/Work/Fusumi/fusumi_final \
  --assume-yes \
  --profile default

# Call initialization functions for each module

# debt_coordinator
aptos move run \
  --function-id "$ACCOUNT_ADDRESS::debt_coordinator::init_module" \
  --profile default

# debt_root
aptos move run \
  --function-id "$ACCOUNT_ADDRESS::debt_root::init_module" \
  --profile default

# dock
aptos move run \
  --function-id "$ACCOUNT_ADDRESS::dock::initialize" \
  --profile default

# fusumi_market (fee_percentage argument, e.g., 2)
aptos move run \
  --function-id "$ACCOUNT_ADDRESS::fusumi_market::initialize" \
  --args "u64:2" \
  --profile default

# fusumi_nft_manager
aptos move run \
  --function-id "$ACCOUNT_ADDRESS::fusumi_nft_manager::initialize" \
  --profile default

# stash
aptos move run \
  --function-id "$ACCOUNT_ADDRESS::stash::initialize" \
  --profile default

echo "Deployment and initialization complete."