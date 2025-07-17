module fusumi_deployer::debt_coordinator {
    use std::signer;
    use std::string::String;
    use std::option::Option;
    use std::vector;
    use fusumi_deployer::dock;
    use fusumi_deployer::stash;
    use fusumi_deployer::fusumi_market_manager;
    use fusumi_deployer::debt_root;

    /// Initialize the entire debt sharing system
    fun init_module(account: &signer) {
        dock::initialize(account);
        stash::initialize(account);
        fusumi_market_manager::initialize(account);
        debt_root::initialize(account);
    }

    /// Entry function for adding a product
    public entry fun load_cargo(
        ship: &signer,
        cargo_name: String,
        cargo_id: u64,
        price: u64,
        unit_of_measure: String,
        description: Option<String>,
        images: vector<String>,
        start_date: u64,
        end_date: u64,
    ) {
        stash::load_cargo(
            ship,
            cargo_name,
            cargo_id,
            price,
            unit_of_measure,
            description,
            images,
            start_date,
            end_date,
        );
    }

    /// Entry function for adding a business
    public entry fun anchoring_ship(
        moderator: &signer,
        ship_imo: address,
    ) {
        dock::anchoring_ship(moderator, ship_imo);
    }

    /// Entry function for removing a business
    public entry fun departing_ship(
        moderator: &signer,
        ship_imo: address,
    ) {
        dock::departing_ship(moderator, ship_imo);
    }
}