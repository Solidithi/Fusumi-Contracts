#[test_only]
module fusumi_deployer::debt_root_tests {
    use std::signer;
    use std::string;
    use std::option;
    use std::vector;
    use fusumi_deployer::debt_root;
    use fusumi_deployer::dock;
    use fusumi_deployer::stash;
    use fusumi_deployer::fusumi_nft_manager;
    use aptos_framework::timestamp;
    use aptos_token::token;
    use aptos_framework::account;

    #[test(fusumi_deployer = @fusumi_deployer, ship = @0x2, aptos_framework = @aptos_framework)]
    fun test_create_debt_root(fusumi_deployer: &signer, ship: &signer, aptos_framework: &signer) {
        let ship_imo = signer::address_of(ship);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        dock::init_for_testing(fusumi_deployer);
        stash::init_for_testing(fusumi_deployer);
        debt_root::initialize_for_testing(fusumi_deployer);
        dock::anchoring_ship(fusumi_deployer, ship_imo);

        let cargo_name = string::utf8(b"Test Cargo");
        let cargo_type = string::utf8(b"Test Type");
        let unit_of_measure = string::utf8(b"tons");
        let description = option::some(string::utf8(b"Test Description"));
        let images = vector::empty<string::String>();

        stash::load_cargo(
            ship,
            cargo_name,
            cargo_type,
            100,
            unit_of_measure,
            description,
            images,
            0,
            0,
        );

        let root_name = string::utf8(b"Test Root");
        let root_description = string::utf8(b"Test Description");
        let root_uri = string::utf8(b"https://example.com");

        debt_root::create_debt_root(
            ship,
            root_name,
            root_description,
            root_uri,
            1000,
            signer::address_of(ship),
            0,
        );
    }
}
