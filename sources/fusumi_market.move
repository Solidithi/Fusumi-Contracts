module fusumi_deployer::fusumi_market {
    use std::error;
    use std::signer;
    use std::string::String;
    use std::table::{Self, Table};
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::event;
    use aptos_framework::timestamp;
    use aptos_token::token::{Self, TokenDataId, TokenId};
    use fusumi_deployer::fusumi_nft_manager;
    use fusumi_deployer::common;

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

    #[event]
    struct NFTListed has drop, store {
        token_id: TokenId,
        seller: address,
        price: u64,
        collection_name: String,
        shared_percentage: u64,
        timestamp: u64,
    }

    #[event]
    struct NFTPurchased has drop, store {
        token_id: TokenId,
        seller: address,
        buyer: address,
        price: u64,
        marketplace_fee: u64,
        collection_name: String,
        timestamp: u64,
    }

    #[event]
    struct NFTDelisted has drop, store {
        token_id: TokenId,
        seller: address,
        collection_name: String,
        timestamp: u64,
    }

    public(friend) fun initialize(account: &signer, fee_percentage: u64) {
        move_to(account, Marketplace {
            listings: table::new(),
            marketplace_fee_percentage: fee_percentage,
        });
    }

    public fun list_nft(
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
        assert!(
            !table::contains(&marketplace.listings, token_id), 
            error::already_exists(common::nft_already_listed())
        );
        assert!
        (
            price > 0, 
            error::invalid_argument(common::invalid_price())
        );
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
        event::emit(NFTListed {
            token_id,
            seller,
            price,
            collection_name,
            shared_percentage,
            timestamp: timestamp::now_seconds(),
        });
    }

    public entry fun purchase_nft(
        buyer: &signer,
        seller: &signer,
        marketplace_address: address,
        creator: address,
        collection: String,
        name: String,
        property_version: u64,
    ) acquires Marketplace {
        let buyer_address = signer::address_of(buyer);
        let marketplace = borrow_global_mut<Marketplace>(marketplace_address);
        let token_id = token::create_token_id(token::create_token_data_id(creator, collection, name), property_version);
        assert!
        (
            table::contains(&marketplace.listings, token_id), 
            error::not_found(common::nft_not_listed())
        );
        let listing = table::remove(&mut marketplace.listings, token_id);
        let marketplace_fee = (listing.price * marketplace.marketplace_fee_percentage) / 100;
        let _seller_amount = listing.price - marketplace_fee;
        let payment_coin = coin::withdraw<AptosCoin>(buyer, listing.price);
        let marketplace_fee_coin = coin::extract(&mut payment_coin, marketplace_fee);
        coin::deposit(listing.seller, payment_coin);
        coin::deposit(marketplace_address, marketplace_fee_coin);
        fusumi_nft_manager::transfer_nft_ownership(listing.seller, buyer_address, listing.collection_creator);
        token::transfer(seller, token_id, buyer_address, 1);
        event::emit(NFTPurchased {
            token_id,
            seller: listing.seller,
            buyer: buyer_address,
            price: listing.price,
            marketplace_fee,
            collection_name: listing.collection_name,
            timestamp: timestamp::now_seconds(),
        });
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
        assert!
        (
            table::contains(&marketplace.listings, token_id), 
            error::not_found(common::nft_not_listed())
        );
        let listing = table::borrow(&marketplace.listings, token_id);
        assert!
        (
            listing.seller == seller_address, 
            error::permission_denied(common::not_nft_owner())
        );
        let listing = table::remove(&mut marketplace.listings, token_id);
        token::transfer(seller, token_id, seller_address, 1);
        event::emit(NFTDelisted {
            token_id,
            seller: seller_address,
            collection_name: listing.collection_name,
            timestamp: timestamp::now_seconds(),
        });
    }

    public entry fun update_listing_price(
        seller: &signer,
        marketplace_address: address,
        creator: address,
        collection: String,
        name: String,
        property_version: u64,
        new_price: u64,
    ) acquires Marketplace {
        let seller_address = signer::address_of(seller);
        let marketplace = borrow_global_mut<Marketplace>(marketplace_address);
        let token_id = token::create_token_id(token::create_token_data_id(creator, collection, name), property_version);
        assert!
        (
            table::contains(&marketplace.listings, token_id), 
            error::not_found(common::nft_not_listed())
        );
        assert!
        (
            new_price > 0, 
            error::invalid_argument(common::invalid_price())
        );
        let listing = table::borrow_mut(&mut marketplace.listings, token_id);
        assert!
        (
            listing.seller == seller_address, 
            error::permission_denied(common::not_nft_owner())
        );
        listing.price = new_price;
    }

    public entry fun update_marketplace_fee(
        owner: &signer,
        new_fee_percentage: u64,
    ) acquires Marketplace {
        let owner_address = signer::address_of(owner);
        assert!
        (
            new_fee_percentage <= 10, 
            error::invalid_argument(common::invalid_fee_percentage())
        );
        let marketplace = borrow_global_mut<Marketplace>(owner_address);
        marketplace.marketplace_fee_percentage = new_fee_percentage;
    }

    #[view]
    /// Get listing information
    public fun get_listing_info(marketplace_address: address, creator: address, collection: String, name: String, property_version: u64): (address, u64, String, u64, u64) acquires Marketplace {
        let marketplace = borrow_global<Marketplace>(marketplace_address);
        let token_id = token::create_token_id(token::create_token_data_id(creator, collection, name), property_version);
        assert!
        (
            table::contains(&marketplace.listings, token_id),
            error::not_found(common::nft_not_listed())
        );
        let listing = table::borrow(&marketplace.listings, token_id);
        (
            listing.seller,
            listing.price,
            listing.collection_name,
            listing.shared_percentage,
            listing.listed_timestamp
        )
    }

    #[view]
    /// Check if NFT is listed
    public fun is_nft_listed(marketplace_address: address, creator: address, collection: String, name: String, property_version: u64): bool acquires Marketplace {
        let marketplace = borrow_global<Marketplace>(marketplace_address);
        let token_id = token::create_token_id(token::create_token_data_id(creator, collection, name), property_version);
        table::contains(&marketplace.listings, token_id)
    }

    #[view]
    /// Get marketplace fee percentage
    public fun get_marketplace_fee_percentage(marketplace_address: address): u64 acquires Marketplace {
        let marketplace = borrow_global<Marketplace>(marketplace_address);
        marketplace.marketplace_fee_percentage
    }

    #[test_only]
    /// must init for external testing file as init is private fun
    public fun init_for_testing(account: &signer) {
        initialize(account, 2);
    }
}