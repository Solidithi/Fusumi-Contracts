#[test_only]
module fusumi_deployer::fusumi_market_tests {
    use std::signer;
    use std::string;
    use fusumi_deployer::fusumi_market;
    use fusumi_deployer::fusumi_nft_manager;
    use fusumi_deployer::common;
    use std::option;
    use aptos_framework::timestamp;
    use aptos_token::token;
    use aptos_framework::account;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_framework::coin;

    #[test(fusumi_deployer = @fusumi_deployer, seller = @0x2, aptos_framework = @aptos_framework)]
    fun test_list_nft(fusumi_deployer: &signer, seller: &signer, aptos_framework: &signer) {
        let seller_address = signer::address_of(seller);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        fusumi_market::init_for_testing(fusumi_deployer);
        fusumi_nft_manager::init_for_testing(fusumi_deployer);
        account::create_account_for_test(seller_address);
        token::opt_in_direct_transfer(seller, true);

        let collection_name = string::utf8(b"Test Collection");
        let token_name = string::utf8(b"Test Token");
        let token_uri = string::utf8(b"https://example.com/token");

        token::create_collection(
            fusumi_deployer,
            collection_name,
            string::utf8(b"Test Collection Description"),
            string::utf8(b"https://example.com/collection"),
            0,
            vector[false, false, false]
        );

        let token_data_id = token::create_tokendata(
            fusumi_deployer,
            collection_name,
            token_name,
            string::utf8(b"Test Token Description"),
            1,
            token_uri,
            signer::address_of(fusumi_deployer),
            1,
            0,
            token::create_token_mutability_config(&vector[false, false, false, false, true]),
            vector[],
            vector[],
            vector[],
        );

        token::mint_token_to(fusumi_deployer, seller_address, token_data_id, 1);

        fusumi_market::list_nft(
            signer::address_of(fusumi_deployer),
            signer::address_of(fusumi_deployer),
            collection_name,
            token_name,
            0,
            seller_address,
            100,
            signer::address_of(fusumi_deployer),
            collection_name,
            token_data_id,
            100,
        );

        assert!(fusumi_market::is_nft_listed(
            signer::address_of(fusumi_deployer),
            signer::address_of(fusumi_deployer),
            collection_name,
            token_name,
            0
        ), 0);
    }

    #[test(fusumi_deployer = @fusumi_deployer, seller = @0x2, buyer = @0x3, aptos_framework = @aptos_framework)]
    fun test_purchase_nft(fusumi_deployer: &signer, seller: &signer, buyer: &signer, aptos_framework: &signer) {
        let seller_address = signer::address_of(seller);
        let buyer_address = signer::address_of(buyer);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);
        fusumi_market::init_for_testing(fusumi_deployer);
        fusumi_nft_manager::init_for_testing(fusumi_deployer);
        account::create_account_for_test(seller_address);
        account::create_account_for_test(buyer_address);
        token::opt_in_direct_transfer(seller, true);
        token::opt_in_direct_transfer(buyer, true);

        let collection_name = string::utf8(b"Test Collection");
        let token_name = string::utf8(b"Test Token");
        let token_uri = string::utf8(b"https://example.com/token");

        token::create_collection(
            fusumi_deployer,
            collection_name,
            string::utf8(b"Test Collection Description"),
            string::utf8(b"https://example.com/collection"),
            0,
            vector[false, false, false]
        );

        let token_data_id = token::create_tokendata(
            fusumi_deployer,
            collection_name,
            token_name,
            string::utf8(b"Test Token Description"),
            1,
            token_uri,
            signer::address_of(fusumi_deployer),
            1,
            0,
            token::create_token_mutability_config(&vector[false, false, false, false, true]),
            vector[],
            vector[],
            vector[],
        );

        token::mint_token_to(fusumi_deployer, seller_address, token_data_id, 1);

        let nft_data = common::new_nft_ownership_data(
            seller_address,
            signer::address_of(fusumi_deployer),
            100,
            option::none(),
            false,
            timestamp::now_seconds(),
            token_name,
            0
        );
        fusumi_nft_manager::add_nft_data(nft_data);

        fusumi_market::list_nft(
            signer::address_of(fusumi_deployer),
            signer::address_of(fusumi_deployer),
            collection_name,
            token_name,
            0,
            seller_address,
            100,
            signer::address_of(fusumi_deployer),
            collection_name,
            token_data_id,
            100,
        );

        let coin = coin::mint<AptosCoin>(100, &mint_cap);
        coin::deposit(buyer_address, coin);

        fusumi_market::purchase_nft(
            buyer,
            seller,
            signer::address_of(fusumi_deployer),
            signer::address_of(fusumi_deployer),
            collection_name,
            token_name,
            0,
        );

        assert!(!fusumi_market::is_nft_listed(
            signer::address_of(fusumi_deployer),
            signer::address_of(fusumi_deployer),
            collection_name,
            token_name,
            0
        ), 1);

        let (owner, _, _, _) = fusumi_nft_manager::get_nft_data_by_owner(buyer_address, signer::address_of(fusumi_deployer));
        assert!(owner == 100, 2);

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }
}