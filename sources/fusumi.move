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
    public entry fun create_debt_root(){

    }

    /// This path will mint the token (NFT) that represents the debt
    public entry fun mint_debt_token(){

    }

    /// Use this path to repay debt to root
    public entry fun deposit_debt_payment(){

    }

    /// Use this path to withdraw debt payment
    public entry fun withdraw_debt_payment(){

    }

    /// Use this path to mint a new token and share the ownership of the debt
    public entry fun parting_token(){

    }
}