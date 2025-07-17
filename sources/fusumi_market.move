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

    public(friend) fun list_nft(
        marketplace_address: address,
        creator: address,
        collection: String,
        name: String,
        property_version: u64,
        seller: address,
        price: u64,
        collection_creator: address,
        collection_name: String,
        token_data_id: TokenDataId,
        shared_percentage: u64,
    ) acquires Marketplace {
        let marketplace = borrow_global_mut<Marketplace>(marketplace_address);
        let token_id = token::create_token_id(token::create_token_data_id(creator, collection, name), property_version);
        assert!(!table::contains(&marketplace.listings, token_id), error::already_exists(0)); // TODO: custom error
        assert!(price > 0, error::invalid_argument(0)); // TODO: custom error
        let listing = Listing {
            token_id,
            seller,
            price,
            collection_creator,
            collection_name,
            token_data_id,
            shared_percentage,
            listed_timestamp: timestamp::now_seconds(),
        };
        table::add(&mut marketplace.listings, token_id, listing);
        // TODO: emit event
    }

    public entry fun purchase_nft(
        buyer: &signer,
        marketplace_address: address,
        creator: address,
        collection: String,
        name: String,
        property_version: u64,
    ) acquires Marketplace {
        let buyer_address = signer::address_of(buyer);
        let marketplace = borrow_global_mut<Marketplace>(marketplace_address);
        let token_id = token::create_token_id(token::create_token_data_id(creator, collection, name), property_version);
        assert!(table::contains(&marketplace.listings, token_id), error::not_found(0)); // TODO: custom error
        let listing = table::remove(&mut marketplace.listings, token_id);
        let marketplace_fee = (listing.price * marketplace.marketplace_fee_percentage) / 100;
        let seller_amount = listing.price - marketplace_fee;
        let payment_coin = coin::withdraw<AptosCoin>(buyer, listing.price);
        let marketplace_fee_coin = coin::extract(&mut payment_coin, marketplace_fee);
        coin::deposit(listing.seller, payment_coin);
        coin::deposit(marketplace_address, marketplace_fee_coin);
        fusumi_nft_manager::transfer_nft_ownership(listing.seller, buyer_address, listing.collection_creator);
        token::transfer(buyer, token_id, buyer_address, 1);
        // TODO: emit event
    }

    public entry fun delist_nft(
        seller: &signer,
        marketplace_address: address,
        creator: address,
        collection: String,
        name: String,
        property_version: u64,
    ) acquires Marketplace {
        let seller_address = signer::address_of(seller);
        let marketplace = borrow_global_mut<Marketplace>(marketplace_address);
        let token_id = token::create_token_id(token::create_token_data_id(creator, collection, name), property_version);
        assert!(table::contains(&marketplace.listings, token_id), error::not_found(0)); // TODO: custom error
        let listing = table::borrow(&marketplace.listings, token_id);
        assert!(listing.seller == seller_address, error::permission_denied(0)); // TODO: custom error
        let listing = table::remove(&mut marketplace.listings, token_id);
        token::transfer(seller, token_id, seller_address, 1);
        // TODO: emit event
    }
}