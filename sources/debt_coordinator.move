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
}