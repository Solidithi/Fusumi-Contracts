module ye_contracts::token_manager {

	use std::string;

	use std::error;

	use std::signer;

	use aptos_framework::coin;

	use aptos_framework::event;

	/// Error codes

	const EINSUFFICIENT_BALANCE: u64 = 1;

	const ETOKEN_NOT_INITIALIZED: u64 = 2;

	const EALREADY_INITIALIZED: u64 = 3;

	const ENOT_OWNER: u64 = 4;

	/// Custom token structure

	struct YeToken has key {}

	/// Token info resource

	struct TokenInfo has key {
		name: string::String,
		symbol: string::String,
		decimals: u8,
		total_supply: u64,
		owner: address,
	}

	/// Events

	struct TokenMintEvent has drop, store {
		to: address,
		amount: u64,
	}

	struct TokenBurnEvent has drop, store {
		from: address,
		amount: u64,
	}

	/// Initialize the token

	public entry fun initialize_token(
		account: &signer,
		name: string::String,
		symbol: string::String,
		decimals: u8,
		initial_supply: u64,
	) {
		let account_addr = signer::address_of(account);
		// Ensure not already initialized
		assert!(!exists<TokenInfo>(account_addr), error::already_exists(EALREADY_INITIALIZED));
		// Initialize coin
		let (burn_cap, freeze_cap, mint_cap) = coin::initialize<YeToken>(
            account,
            name,
            symbol,
            decimals,
            true, // monitor_supply
        );
		// Store token info
		let token_info = TokenInfo {
            name,
            symbol,
            decimals,
            total_supply: initial_supply,
            owner: account_addr,
        };
		move_to(account, token_info);
		// Mint initial supply
		if (initial_supply > 0) {
            let coins = coin::mint<YeToken>(initial_supply, &mint_cap);
            coin::deposit(account_addr, coins);
            
            event::emit(TokenMintEvent {
                to: account_addr,
                amount: initial_supply,
            });
        };
		// Store capabilities (in a real implementation, you might want to handle these differently)
		coin::destroy_burn_cap(burn_cap);
		coin::destroy_freeze_cap(freeze_cap);
		coin::destroy_mint_cap(mint_cap);
	}

	/// Mint tokens (only owner can mint)

	public entry fun mint_tokens(
		owner: &signer,
		to: address,
		amount: u64,
	)acquires TokenInfo {
		let owner_addr = signer::address_of(owner);
		// Check if token is initialized
		assert!(exists<TokenInfo>(owner_addr), error::not_found(ETOKEN_NOT_INITIALIZED));
		let token_info = borrow_global_mut<TokenInfo>(owner_addr);
		// Check if caller is owner
		assert!(token_info.owner == owner_addr, error::permission_denied(ENOT_OWNER));
		// Update total supply
		token_info.total_supply = token_info.total_supply + amount;
		// Note: In a real implementation, you would need to store and use mint capability
		// For this example, we'll just emit the event
		event::emit(TokenMintEvent {
            to,
            amount,
        });
	}

	/// Transfer tokens

	public entry fun transfer(from: &signer, to: address, amount: u64) {
		coin::transfer<YeToken>(from, to, amount);
	}

	/// Get token balance

	#[view]

	public fun balance(account: address): u64 {
		coin::balance<YeToken>(account)
	}

	/// Get token info

	#[view]

	public fun get_token_info(
		token_owner: address,
	): (string::String, string::String, u8, u64)acquires TokenInfo {
		assert!(exists<TokenInfo>(token_owner), error::not_found(ETOKEN_NOT_INITIALIZED));
		let token_info = borrow_global<TokenInfo>(token_owner);
		(token_info.name, token_info.symbol, token_info.decimals, token_info.total_supply)
	}

	/// Check if token is initialized

	#[view]

	public fun is_token_initialized(token_owner: address): bool {
		exists<TokenInfo>(token_owner)
	}

	#[test_only]

	use aptos_framework::account;

	#[test(owner = @0x1)]

	public entry fun test_token_initialization(
		owner: signer,
	)acquires TokenInfo {
		let owner_addr = signer::address_of(&owner);
		// Initialize token
		initialize_token(
            &owner,
            string::utf8(b"Ye Token"),
            string::utf8(b"YE"),
            8,
            1000000,
        );
		// Check if initialized
		assert!(is_token_initialized(owner_addr), 1);
		// Check token info
		let (name, symbol, decimals, total_supply) = get_token_info(owner_addr);
		assert!(name == string::utf8(b"Ye Token"), 2);
		assert!(symbol == string::utf8(b"YE"), 3);
		assert!(decimals == 8, 4);
		assert!(total_supply == 1000000, 5);
	}
}
