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
        withdrawn_amounts: u64,
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
        let withdrawn_amounts = table::new<u64, u64>();
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
            withdrawn_amounts,
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

    /// Mint a new debt NFT with specified shared percentage
    /// 1st minter is the creator and need to pass 100% shared percentage
    /// parted NFTs will have less and this function will be called through derive_nft
    public entry fun mint_debt_token(
        creator: &signer,
        receiver: address,
        root_name: String,
        shared_percentage: u64,
        parent_token_id: Option<u64>,
    ) acquires DebtRootRegistry {
        let creator_address = signer::address_of(creator);
        let registry = borrow_global_mut<DebtRootRegistry>(creator_address);
        assert!(table::contains(&registry.debts, root_name), error::not_found(0)); // TODO: replace 0 with custom error

        let debt_root = table::borrow_mut(&mut registry.debts, root_name);
        assert!(
            debt_root.total_shared_percentage + shared_percentage <= 100,
            error::invalid_argument(common::max_shared_percentage_exceeded())
        );

        let mut token_name = string::utf8(b"Debt Token #");
        string::append(&mut token_name, string::utf8(bcs::to_bytes(&debt_root.next_token_id)));
        let mut token_uri = string::utf8(b"https://debt-nft.com/token/");
        string::append(&mut token_uri, string::utf8(bcs::to_bytes(&debt_root.next_token_id)));

        let individual_token_data_id = token::create_tokendata(
            creator,
            root_name,
            token_name,
            string::utf8(b"Debt sharing token"),
            1,
            token_uri,
            creator_address,
            1,
            0,
            token::create_token_mutability_config(&vector<bool>[false, false, false, false, true]),
            vector<String>[
                string::utf8(b"shared"),
                string::utf8(b"parent_token_id"),
                string::utf8(b"is_root"),
                string::utf8(b"created_at"),
                string::utf8(b"cargo_id")
            ],
            vector<vector<u8>>[
                bcs::to_bytes(&shared_percentage),
                bcs::to_bytes(&parent_token_id),
                bcs::to_bytes(&false),
                bcs::to_bytes(&timestamp::now_seconds()),
                bcs::to_bytes(&debt_root.cargo_id)
            ],
            vector<String>[
                string::utf8(b"u64"),
                string::utf8(b"option<u64>"),
                string::utf8(b"bool"),
                string::utf8(b"u64"),
                string::utf8(b"string")
            ],
        );

        token::mint_token_to(creator, receiver, individual_token_data_id, 1);

        let nft_data = common::new_nft_ownership_data(
            receiver,
            creator_address,
            shared_percentage,
            parent_token_id,
            false, // is_root_nft is false for parting tokens
            timestamp::now_seconds(),
            token_name,
            debt_root.next_token_id
        );

        table::add(
            &mut debt_root.withdrawn_amounts,
            receiver,
            0
        );
        debt_root.total_shared_percentage = debt_root.total_shared_percentage + shared_percentage;
        let current_token_id = debt_root.next_token_id;
        debt_root.next_token_id = debt_root.next_token_id + 1;

        event::emit(DebtTokenMinted {
            debt_root_name: root_name,
            token_id: current_token_id,
            receiver,
            shared_percentage,
            parent_token_id,
            created_at: timestamp::now_seconds(),
        });
    }

    /// Deposit a payment towards the debt root
    public entry fun deposit_debt_payment(
        debtor: &signer,
        root_creator: address,
        root_name: String,
        payment_amount: u64,
    ) acquires DebtRootRegistry {
        let debtor_address = signer::address_of(debtor);
        let registry = borrow_global_mut<DebtRootRegistry>(root_creator);
        assert!(table::contains(&registry.debts, root_name), error::not_found(0)); // TODO: replace 0 with custom error

        let debt_root = table::borrow_mut(&mut registry.debts, root_name);
        assert!(debt_root.debtor_address == debtor_address, error::permission_denied(0)); // TODO: replace 0 with custom error
        assert!(payment_amount > 0, error::invalid_argument(0)); // TODO: replace 0 with custom error

        let payment_coin = coin::withdraw<AptosCoin>(debtor, payment_amount);
        coin::merge(&mut debt_root.debt_vault, payment_coin);
        debt_root.total_paid_amount = debt_root.total_paid_amount + payment_amount;

        event::emit(DebtPaymentDeposited {
            debt_root_name: root_name,
            amount: payment_amount,
            total_paid_amount: debt_root.total_paid_amount,
            depositor: debtor_address,
            created_at: timestamp::now_seconds(),
        });
    }

    /// Withdraw a payment from the debt root
    public entry fun withdraw_debt_payment(
        withdrawer: &signer,
        root_creator: address,
        root_name: String,
        withdrawal_amount: u64,
    ) acquires DebtRootRegistry {
        let withdrawer_address = signer::address_of(withdrawer);
        let registry = borrow_global_mut<DebtRootRegistry>(root_creator);
        assert!(table::contains(&registry.debts, root_name), error::not_found(0)); // TODO: replace 0 with custom error

        let debt_root = table::borrow_mut(&mut registry.debts, root_name);
        // Find NFT/token data by owner (assume similar logic as before, adapt as needed)
        let nft_data_opt = common::find_nft_data_by_owner(withdrawer_address, root_creator);
        assert!(option::is_some(&nft_data_opt), error::not_found(0)); // TODO: replace 0 with custom error

        let nft_data = option::extract(&mut nft_data_opt);
        let already_withdrawn = if (table::contains(&debt_root.withdrawn_amounts, withdrawer_address)) {
            *table::borrow(&debt_root.withdrawn_amounts, withdrawer_address)
        } else {
            0
        };

        let total_entitled = (debt_root.total_paid_amount * common::nft_shared_percentage(&nft_data)) / 100;
        let available_to_withdraw = total_entitled - already_withdrawn;
        assert!(withdrawal_amount <= available_to_withdraw, error::invalid_argument(0)); // TODO: replace 0 with custom error
        assert!(coin::value(&debt_root.debt_vault) >= withdrawal_amount, error::invalid_argument(0)); // TODO: replace 0 with custom error

        let withdrawal_coin = coin::extract(&mut debt_root.debt_vault, withdrawal_amount);
        coin::deposit(withdrawer_address, withdrawal_coin);

        let new_withdrawn_total = already_withdrawn + withdrawal_amount;
        if (table::contains(&debt_root.withdrawn_amounts, withdrawer_address)) {
            *table::borrow_mut(&mut debt_root.withdrawn_amounts, withdrawer_address) = new_withdrawn_total;
        } else {
            table::add(&mut debt_root.withdrawn_amounts, withdrawer_address, new_withdrawn_total);
        };

        event::emit(DebtPaymentWithdrawn {
            debt_root_name: root_name,
            amount: withdrawal_amount,
            total_withdrawn_amount: new_withdrawn_total,
            withdrawer: withdrawer_address,
            created_at: timestamp::now_seconds(),
        });
    }

    /// Share ownership of the debt by minting a new token
    /// Derive a new debt token from an existing one and list it on the marketplace
    public entry fun parting_token(
        creator: &signer,
        parent_token_owner: address,
        marketplace_address: address,
        root_name: String,
        parent_token_id: u64,
        parted_shared_percentage: u64,
        listing_price: u64,
    ) acquires DebtRootRegistry {
        let creator_address = signer::address_of(creator);
        // Get parent shared percentage
        let parent_shared_percentage = common::get_nft_shared_percentage(parent_token_owner, creator_address);
        assert!(parted_shared_percentage <= parent_shared_percentage, error::invalid_argument(0)); // TODO: replace 0 with custom error
        assert!(listing_price > 0, error::invalid_argument(0)); // TODO: replace 0 with custom error

        // Update parent token's shared percentage
        common::update_nft_shared_percentage(parent_token_owner, creator_address, parent_shared_percentage - parted_shared_percentage);
        let parent_id = common::get_nft_token_id(parent_token_owner, creator_address);

        // Mint the new token to the marketplace initially
        Self::mint_debt_token(
            creator,
            marketplace_address,
            root_name,
            parted_shared_percentage,
            option::some(parent_token_id)
        );

        let new_token_id = {
            let registry = borrow_global<DebtRootRegistry>(creator_address);
            let debt_root = table::borrow(&registry.debts, root_name);
            debt_root.next_token_id - 1
        };

        // Create the token name for the newly minted token
        let mut token_name = string::utf8(b"Debt Token #");
        string::append(&mut token_name, string::utf8(bcs::to_bytes(&new_token_id)));

        let token_data_id = token::create_token_data_id(creator_address, root_name, token_name);

        // List the token on the marketplace (adapt as needed for your market module)
        fusumi_market::list_nft(
            marketplace_address,
            creator_address,
            root_name,
            token_name,
            0,
            parent_token_owner, // Original owner is the seller
            listing_price,
            creator_address,
            root_name,
            token_data_id,
            parted_shared_percentage,
        );

        event::emit(TokenParted {
            debt_root_name: root_name,
            parent_token_id: parent_id,
            new_token_id,
            parent_owner: parent_token_owner,
            maraketplace_address: marketplace_address,
            parted_percentage: parted_shared_percentage,
            listing_price,
            created_at: timestamp::now_seconds(),
        });
    }

        #[view]
    /// View function to get debt root info
    public fun get_debt_root_info(root_creator: address, root_name: String): (String, u64, u64, address, u64, u64, u64) acquires DebtRootRegistry {
        let registry = borrow_global<DebtRootRegistry>(root_creator);
        let debt_root = table::borrow(&registry.debts, root_name);
        (
            debt_root.root_name,
            debt_root.total_debt_amount,
            debt_root.total_paid_amount,
            debt_root.debtor_address,
            debt_root.total_shared_percentage,
            coin::value(&debt_root.debt_vault),
            debt_root.cargo_id
        )
    }

    #[view]
    /// Calculate available withdrawal amount for a token holder
    public fun calculate_available_withdrawal(root_creator: address, root_name: String, token_owner: address): u64 acquires DebtRootRegistry {
        let registry = borrow_global<DebtRootRegistry>(root_creator);
        let debt_root = table::borrow(&registry.debts, root_name);
        let nft_data_opt = common::find_nft_data_by_owner(token_owner, root_creator);
        if (option::is_some(&nft_data_opt)) {
            let nft_data = option::extract(&mut nft_data_opt);
            let total_entitled = (debt_root.total_paid_amount * common::nft_shared_percentage(&nft_data)) / 100;
            let already_withdrawn = if (table::contains(&debt_root.withdrawn_amounts, token_owner)) {
                *table::borrow(&debt_root.withdrawn_amounts, token_owner)
            } else {
                0
            };
            total_entitled - already_withdrawn
        } else {
            0
        }
    }

    #[view]
    /// Get total withdrawn amount by a token holder
    public fun get_total_withdrawn(root_creator: address, root_name: String, token_owner: address): u64 acquires DebtRootRegistry {
        let registry = borrow_global<DebtRootRegistry>(root_creator);
        let debt_root = table::borrow(&registry.debts, root_name);
        if (table::contains(&debt_root.withdrawn_amounts, token_owner)) {
            *table::borrow(&debt_root.withdrawn_amounts, token_owner)
        } else {
            0
        }
    }

    #[view]
    /// Get comprehensive token holder info
    public fun get_token_holder_info(root_creator: address, root_name: String, token_owner: address): (u64, u64, u64, u64) acquires DebtRootRegistry {
        let registry = borrow_global<DebtRootRegistry>(root_creator);
        let debt_root = table::borrow(&registry.debts, root_name);
        let nft_data_opt = common::find_nft_data_by_owner(token_owner, root_creator);
        if (option::is_some(&nft_data_opt)) {
            let nft_data = option::extract(&mut nft_data_opt);
            let total_entitled = (debt_root.total_paid_amount * common::nft_shared_percentage(&nft_data)) / 100;
            let already_withdrawn = if (table::contains(&debt_root.withdrawn_amounts, token_owner)) {
                *table::borrow(&debt_root.withdrawn_amounts, token_owner)
            } else {
                0
            };
            let available = total_entitled - already_withdrawn;
            (common::nft_shared_percentage(&nft_data), total_entitled, already_withdrawn, available)
        } else {
            (0, 0, 0, 0)
        }
    }

    #[test_only]
    /// must init for external testing file as init is private fun
    public fun initialize_for_testing(account: &signer) {
        initialize(account);
    }
}