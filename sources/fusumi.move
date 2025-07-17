module fusumi_deployer::fusumi {
    use fusumi_deployer::debt_coordinator;
    use std::string::String;
    use std::option::Option;
    use std::vector;

    /// Add business
    public entry fun anchoring_ship(
        moderator: &signer,
        ship_imo: address,
    ){
        debt_coordinator::anchoring_ship(moderator, ship_imo);
    }

    /// Remove business
    public entry fun departing_ship(
        moderator: &signer,
        ship_imo: address,
    ){
        debt_coordinator::departing_ship(moderator, ship_imo);
    }

    /// Create product
    /// Business and product relationships are 1:n
    public entry fun load_cargo(
        ship: &signer,
        cargo_name: String,
        cargo_type: String,
        cargo_price: u64,
        cargo_unit_of_measure: String,
        cargo_description: Option<String>,
        cargo_images: vector<String>,
        cargo_start_date: u64,
        cargo_end_date: u64,
    ){
        debt_coordinator::load_cargo(
            ship,
            cargo_name,
            cargo_type,
            cargo_price,
            cargo_unit_of_measure,
            cargo_description,
            cargo_images,
            cargo_start_date,
            cargo_end_date,
        );
    }

    /// Dept root is where the debt is repaid, no one own this
    public entry fun create_debt_root(
        creator: &signer,
        root_name: String,
        root_description: String,
        root_uri: String,
        total_debt_amount: u64,
        debtor_address: address,
        cargo_id: u64,
    ) {
        debt_coordinator::create_debt_root(
            creator,
            root_name,
            root_description,
            root_uri,
            total_debt_amount,
            debtor_address,
            cargo_id,
        );
    }

    /// This path will mint the token (NFT) that represents the debt
    public entry fun mint_debt_token(
        creator: &signer,
        receiver: address,
        root_name: String,
        shared_percentage: u64,
        parent_token_id: Option<u64>,
    ) {
        debt_coordinator::mint_debt_token(
            creator,
            receiver,
            root_name,
            shared_percentage,
            parent_token_id
        );
    }

    /// Use this path to repay debt to root
    public entry fun deposit_debt_payment(
        debtor: &signer,
        collection_creator: address,
        root_name: String,
        payment_amount: u64,
    ) {
        debt_coordinator::deposit_debt_payment(
            debtor,
            collection_creator,
            root_name,
            payment_amount
        );
    }

    /// Use this path to withdraw debt payment
    public entry fun withdraw_debt_payment(
        withdrawer: &signer,
        collection_creator: address,
        root_name: String,
        withdrawal_amount: u64,
    ) {
        debt_coordinator::withdraw_debt_payment(
            withdrawer,
            collection_creator,
            root_name,
            withdrawal_amount
        );
    }

    /// Use this path to mint a new token and share the ownership of the debt
    public entry fun parting_token(
        creator: &signer,
        parent_nft_owner: address,
        marketplace_address: address,
        root_name: String,
        parent_token_id: u64,
        shared_percentage: u64,
        listing_price: u64,
    ) {
        debt_coordinator::parting_token(
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
        debt_coordinator::get_debt_root_info(root_creator, root_name)
    }

    #[view]
    public fun calculate_available_withdrawal(root_creator: address, root_name: String, token_owner: address): u64 {
        debt_coordinator::calculate_available_withdrawal(root_creator, root_name, token_owner)
    }

    #[view]
    public fun get_total_withdrawn(root_creator: address, root_name: String, token_owner: address): u64 {
        debt_coordinator::get_total_withdrawn(root_creator, root_name, token_owner)
    }

    #[view]
    public fun get_token_holder_info(root_creator: address, root_name: String, token_owner: address): (u64, u64, u64, u64) {
        debt_coordinator::get_token_holder_info(root_creator, root_name, token_owner)
    }

    #[view]
    public fun is_ship_anchored_view(ship_imo: address): bool {
        debt_coordinator::is_ship_anchored_view(ship_imo)
    }

    #[view]
    public fun get_all_ships(): vector<address> {
        debt_coordinator::get_all_ships()
    }

    #[view]
    public fun get_moderator(): address {
        debt_coordinator::get_moderator()
    }

    #[view]
    public fun get_cargo_info(cargo_id: u64): (address, String, Option<String>, u64, String, String, vector<String>, u64, u64, u64, u64) {
        debt_coordinator::get_cargo_info(cargo_id)
    }

    #[view]
    public fun cargo_exists_view(cargo_id: u64): bool {
        debt_coordinator::cargo_exists_view(cargo_id)
    }

    #[view]
    public fun get_cargos_by_ship(ship_imo: address): vector<u64> {
        debt_coordinator::get_cargos_by_ship(ship_imo)
    }
}