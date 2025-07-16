module fusumi_deployer::fusumi_market {
    use std::error;
    use std::signer;
    use std::string::String;
    use std::option::{Self, Option};
    use std::table::{Self, Table};
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::event;
    use aptos_framework::timestamp;
    use aptos_tokens::token::{Self, TokenDataId, TokenId};
    use fusumi_deployer::fusumi_nft_manager;

    friend fusumi_deployer::debt_root;

    struct Listing has store, drop {
        token_id: TokenId,
        seller: address,
        price: u64,
        collection_creator: address,
        collection_name: String,
        token_data_id: TokenDataId,
        shared_percentage: u64,
        listed_timestamp: u64,
    }

    struct Marketplace has key {
        listings: Table<TokenId, Listing>,
        marketplace_fee_percentage: u64, // Fee percentage (e.g., 2 for 2%)
    }

    public(friend) fun initialize(account: &signer, fee_percentage: u64) {
        move_to(account, Marketplace {
            listings: table::new(),
            marketplace_fee_percentage: fee_percentage,
        });
    }

    public(friend) fun list_nft(){

    }

    public entry fun purchase_nft(){

    }

    public entry fun delist_nft(){

    }
}