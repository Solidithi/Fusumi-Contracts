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
    use fusumi_deployer::dock;
    use fusumi_deployer::stash;

    friend fusumi_deployer::debt_coordinator;

    struct DebtRoot has store {

    }

    struct DebtRootRegistry has key {
        debts: Table<String, DebtRoot>,
    }

    /// Initialize the debt root module
    public fun init_module(account: &signer) {
        move_to(account, DebtRootRegistry {
            debts: table::new(),
        });
    }

    /// Create a new debt root
    public entry fun create_debt_root(){
    
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