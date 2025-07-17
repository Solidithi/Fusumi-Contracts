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

    public entry fun create_debt_root(
        creator: &signer,
        root_name: String,
        root_description: String,
        root_uri: String,
        total_debt_amount: u64,
        debtor_address: address,
        cargo_id: u64,
    ) {
        debt_root::create_debt_root
        (
            creator,
            root_name,
            root_description,
            root_uri,
            total_debt_amount,
            debtor_address,
            cargo_id,
        );
    }

    public entry fun mint_debt_token(
        creator: &signer,
        receiver: address,
        root_name: String,
        shared_percentage: u64,
        parent_token_id: Option<u64>,
    ) {
        debt_root::mint_debt_token
        (
            creator,
            receiver,
            root_name,
            shared_percentage,
            parent_token_id
        );
    }

    public entry fun deposit_debt_payment(
        debtor: &signer,
        collection_creator: address,
        root_name: String,
        payment_amount: u64,
    ) {
        debt_root::deposit_debt_payment
        (
            debtor,
            collection_creator,
            root_name,
            payment_amount
        );
    }

    public entry fun withdraw_debt_payment(
        withdrawer: &signer,
        collection_creator: address,
        root_name: String,
        withdrawal_amount: u64,
    ) {
        debt_root::withdraw_debt_payment
        (
            withdrawer,
            collection_creator,
            root_name,
            withdrawal_amount
        );
    }

    public entry fun parting_token(
        creator: &signer,
        parent_nft_owner: address,
        marketplace_address: address,
        root_name: String,
        parent_token_id: u64,
        shared_percentage: u64,
        listing_price: u64,
    ) {
        debt_root::parting_token
        (
            creator,
            parent_nft_owner,
            marketplace_address,
            root_name,
            parent_token_id,
            shared_percentage,
            listing_price
        );
    }

    #[view]
    public fun get_debt_root_info(root_creator: address, root_name: String): (String, u64, u64, address, u64, u64, u64) {
        debt_root::get_debt_root_info(root_creator, root_name)
    }

    #[view]
    public fun calculate_available_withdrawal(root_creator: address, root_name: String, token_owner: address): u64 {
        debt_root::calculate_available_withdrawal(root_creator, root_name, token_owner)
    }

    #[view]
    public fun get_total_withdrawn(root_creator: address, root_name: String, token_owner: address): u64 {
        debt_root::get_total_withdrawn(root_creator, root_name, token_owner)
    }

    #[view]
    public fun get_token_holder_info(root_creator: address, root_name: String, token_owner: address): (u64, u64, u64, u64) {
        debt_root::get_token_holder_info(root_creator, root_name, token_owner)
    }

    #[view]
    public fun is_ship_anchored_view(ship_imo: address): bool {
        dock::is_ship_anchored_view(ship_imo)
    }

    #[view]
    public fun get_all_ships(): vector<address> {
        dock::get_all_ships()
    }

    #[view]
    public fun get_moderator(): address {
        dock::get_moderator()
    }

    #[view]
    public fun get_cargo_info(cargo_id: u64): (address, String, Option<String>, u64, String, String, vector<String>, u64, u64, u64, u64) {
        stash::get_cargo_info(cargo_id)
    }

    #[view]
    public fun cargo_exists_view(cargo_id: u64): bool {
        stash::cargo_exists_view(cargo_id)
    }

    #[view]
    public fun get_cargos_by_ship(ship_imo: address): vector<u64> {
        stash::get_cargos_by_ship(ship_imo)
    }

    #[view]
    public fun get_nft_data_by_owner(owner: address, collection_creator: address): (u64, Option<u64>, bool, u64) {
        fusumi_market_manager::get_nft_data_by_owner(owner, collection_creator)
    }
}