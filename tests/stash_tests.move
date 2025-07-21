#[test_only]
module fusumi_deployer::stash_tests {
    use std::signer;
    use std::string;
    use std::option;
    use std::vector;
    use fusumi_deployer::stash;
    use fusumi_deployer::dock;
    use aptos_framework::timestamp;

    #[test(fusumi_deployer = @fusumi_deployer, ship = @0x2, aptos_framework = @aptos_framework)]
    fun test_load_cargo_and_verify_ownership(fusumi_deployer: &signer, ship: &signer, aptos_framework: &signer) {
        let ship_imo = signer::address_of(ship);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        dock::init_for_testing(fusumi_deployer);
        stash::init_for_testing(fusumi_deployer);
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

        assert!(stash::cargo_exists_view(0), 0);
        stash::verify_cargo_ownership(0, ship_imo);
    }
}