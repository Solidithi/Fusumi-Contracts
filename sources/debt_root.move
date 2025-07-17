/// Debt root module
module fusumi_deployer::debt_root {
    use std::bcs;
    use std::error;
    use std::signer;
    use std::string::{Self, String};
    use std::option::{Self, Option};
    use std::table::{Self, Table};
    use std::vector;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::event;
    use aptos_framework::timestamp;
    use aptos_tokens::token::{Self, TokenDataId, TokenId};
    use fusumi_deployer::common;
    use fusumi_deployer::dock;
    use fusumi_deployer::stash;
    use fusumi_deployer::fusumi_market_manager;
    use fusumi_deployer::fusumi_market;

    friend fusumi_deployer::debt_coordinator;

    struct DebtRoot has store {
        root_name: String,
        total_debt_amount: u64,
        total_paid_amount: u64,
        debtor_address: address,
        token_data_id: TokenDataId,
        next_token_id: u64,
        total_shared_percentage: u64,
        created_at: u64,
        debt_vault: coin::Coin<AptosCoin>,
        withdrawn_amount: u64,
        cargo_id: u64,
    }

    struct DebtRootRegistry has key {
        debts: Table<String, DebtRoot>,
    }

    // events
    #[event]
    struct DebtRootCreated {
        root_name: String,
        total_debt_amount: u64,
        debtor_address: address,
        creator_address: address,
        cargo_id: u64,
        created_at: u64,
    }

    #[event]
    struct DebtTokenMinted {
        debt_root_name: String,
        token_id: u64,
        receiver: address,
        shared_percentage: u64,
        parent_token_id: Option<u64>,
        created_at: u64,
    }

    #[event]
    struct DebtPaymentDeposited {
        debt_root_name: String,
        amount: u64,
        total_paid_amount: u64,
        depositor: address,
        created_at: u64,
    }

    #[event]
    struct DebtPaymentWithdrawn {
        debt_root_name: String,
        amount: u64,
        total_withdrawn_amount: u64,
        withdrawer: address,
        created_at: u64,
    }

    #[event]
    struct TokenParted {
        debt_root_name: String,
        parent_token_id: u64,
        new_token_id: u64,
        parent_owner: address,
        maraketplace_address: address,
        parted_percentage: u64,
        listing_price: u64,
        created_at: u64,
    }


    /// Initialize the debt root registry (internal)
    public(friend) fun initialize(account: &signer) {
        move_to(account, DebtRootRegistry {
            debts: table::new(),
        });
    }

    /// Create a new debt root
    public entry fun create_debt_root(
        creator: &signer,
        root_name: String,
        root_description: String,
        root_uri: String,
        total_debt_amount: u64,
        debtor_address: address,
        cargo_id: u64,
    ) acquires DebtRootRegistry {
        let creator_address = signer::address_of(creator);
        // Auto-initialize DebtRootRegistry if not present
        if (!exists<DebtRootRegistry>(creator_address)) {
            move_to(creator, DebtRootRegistry {
                debts: table::new(),
            });
        };

        // Perform some verifications
        dock::verify_ship_authorization(creator_address);
        stash::cargo_existed(cargo_id);

        let mutate_setting = vector<bool>[false, false, false];
        token::create_collection(
            creator,
            root_name,
            root_description,
            root_uri,
            0,
            mutate_setting
        );

        // Create root token data (placeholder, adapt as needed)
        let token_name = string::utf8(b"Root Debt Token");
        let token_uri = string::utf8(b"https://debt-nft.com/root");
        let token_data_id = token::create_tokendata(
            creator,
            root_name,
            token_name,
            string::utf8(b"Root token for debt root"),
            0,
            token_uri,
            creator_address,
            1,
            0,
            aptos_tokens::token::create_token_mutability_config(&vector<bool>[false, false, false, false, true]),
            vector<String>[
                string::utf8(b"shared"),
                string::utf8(b"debt_amount"),
                string::utf8(b"is_root"),
                string::utf8(b"created_at"),
                string::utf8(b"cargo_id")
            ],
            vector<vector<u8>>[
                bcs::to_bytes(&0u64),
                bcs::to_bytes(&total_debt_amount),
                bcs::to_bytes(&true),
                bcs::to_bytes(&timestamp::now_seconds()),
                bcs::to_bytes(&cargo_id)
            ],
            vector<String>[
                string::utf8(b"u64"),
                string::utf8(b"u64"),
                string::utf8(b"bool"),
                string::utf8(b"u64"),
                string::utf8(b"string")
            ],
        );

        let debt_vault = coin::zero<AptosCoin>();
        let debt_root = DebtRoot {
            root_name: root_name,
            total_debt_amount,
            total_paid_amount: 0,
            debtor_address,
            token_data_id,
            next_token_id: 0,
            total_shared_percentage: 0,
            created_at: timestamp::now_seconds(),
            debt_vault,
            withdrawn_amount: 0,
            cargo_id,
        };
        let registry = borrow_global_mut<DebtRootRegistry>(creator_address);
        assert!(!table::contains(&registry.debts, root_name), error::invalid_state(0)); // TODO: replace 0 with custom error
        table::add(&mut registry.debts, root_name, debt_root);

        event::emit(DebtRootCreated {
            root_name,
            total_debt_amount,
            debtor_address,
            creator_address,
            cargo_id,
            created_at: timestamp::now_seconds(),
        });
    }

    /// Mint a debt token representing the debt
    public entry fun mint_debt_token() {

    }

    /// Deposit a payment towards the debt root
    public entry fun deposit_debt_payment() {
        // Implementation for depositing a payment
    }

    /// Withdraw a payment from the debt root
    public entry fun withdraw_debt_payment() {
        // Implementation for withdrawing a payment
    }

    /// Share ownership of the debt by minting a new token
    public entry fun parting_token() {
        
    }
}