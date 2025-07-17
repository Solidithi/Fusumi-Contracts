/// Fusumi common code
module fusumi_deployer::common {
    use std::string::String;
    use std::option::Option;
    use std::vector;

    /// Error codes
    const E_CARGO_ALR_EXISTED: u64 = 1;
    const E_NOT_AUTHORIZED: u64 = 2;
    const E_MAX_SHARED_PERCENTAGE_EXCEEDED: u64 = 3;
    const E_INVALID_SHARED_PERCENTAGE: u64 = 4;
    const E_INVALID_PRICE: u64 = 5;
    const E_INSUFFICIENT_WITHDRAWABLE_AMOUNT: u64 = 6;
    const E_INSUFFICIENT_DEBT_BALANCE: u64 = 7;
    const E_NOT_NFT_OWNER: u64 = 8;
    const E_DEBT_ROOT_NOT_FOUND: u64 = 9;
    const E_NOT_DEBTOR: u64 = 10;
    const E_INVALID_PAYMENT_AMOUNT: u64 = 11;
    const E_DEBT_ROOT_ALREADY_EXISTS: u64 = 12;
    const E_NFT_NOT_LISTED: u64 = 13;
    const E_INVALID_FEE_PERCENTAGE: u64 = 14;

    /// Cargo information structure
    struct Cargo has store, drop, copy {
        id: u64,
        ship_imo: address, // business address
        cargo_name: String,
        cargo_type: String,
        price: u64,
        unit_of_measure: String,
        description: Optionl<String>,
        images: vector<String>,
        start_date: u64,
        end_date: u64,
        created_at: u64,
        updated_at: u64
    }

    struct NFTOwnershipData has store, drop, copy {
        owner: address,
        collection_creator: address,
        shared_percentage: u64,
        parent_token_id: Option<u64>,
        is_root_nft: bool,
        created_timestamp: u64,
        token_name: String,
        token_id: u64,
    }

    // Getter for err code
    public fun cargo_alr_existed(): u64 {E_CARGO_ALR_EXISTED}
    public fun not_authorized(): u64 {E_NOT_AUTHORIZED}
    public fun max_shared_percentage_exceeded(): u64 {E_MAX_SHARED_PERCENTAGE_EXCEEDED}
    public fun invalid_shared_percentage(): u64 {E_INVALID_SHARED_PERCENTAGE}
    public fun invalid_price(): u64 {E_INVALID_PRICE}
    public fun insufficient_withdrawable_amount(): u64 {E_INSUFFICIENT_WITHDRAWABLE_AMOUNT} 
    public fun insufficient_debt_balance(): u64 {E_INSUFFICIENT_DEBT_BALANCE}
    public fun not_nft_owner(): u64 {E_NOT_NFT_OWNER}
    public fun debt_root_not_found(): u64 {E_DEBT_ROOT_NOT_FOUND}
    public fun not_debtor(): u64 {E_NOT_DEBTOR}
    public fun invalid_payment_amount(): u64 {E_INVALID_PAYMENT_AMOUNT}
    public fun debt_root_already_exists(): u64 {E_DEBT_ROOT_ALREADY_EXISTS}
    public fun nft_not_listed(): u64 {E_NFT_NOT_LISTED}
    public fun invalid_fee_percentage(): u64 {E_INVALID_FEE_PERCENTAGE}

    // Getter for cargo info
    public fun cargo_id(cargo: &Cargo): u64 {cargo.id}
    public fun cargo_ship_imo(cargo: &Cargo): address {cargo.ship_imo}
    public fun cargo_name(cargo: &Cargo): String {cargo.cargo_name}
    public fun cargo_type(cargo: &Cargo): String {cargo.cargo_type}
    public fun cargo_price(cargo: &Cargo): u64 {cargo.price}
    public fun cargo_unit_of_measure(cargo: &Cargo): String {cargo.unit_of_measure}
    public fun cargo_description(cargo: &Cargo): Option<String> {cargo.description}
    public fun cargo_images(cargo: &Cargo): vector<String> {cargo.images}
    public fun cargo_start_date(cargo: &Cargo): u64 {cargo.start_date}
    public fun cargo_end_date(cargo: &Cargo): u64 {cargo.end_date}
    public fun cargo_created_at(cargo: &Cargo): u64 {cargo.created_at}
    public fun cargo_updated_at(cargo: &Cargo): u64 {cargo.updated_at}

    // Constructor functions for structs
    public fun new_cargo(
        id: u64,
        business_address: address,
        product_name: String,
        product_type: String,
        price: u64,
        unit_of_measure: String,
        description: Option<String>,
        images: vector<String>,
        start_date: u64,
        end_date: u64,
        created_at: u64,
        updated_at: u64,
    ): Product {
        Product {
            id,
            business_address,
            product_name,
            product_type,
            price,
            unit_of_measure,
            description,
            images,
            start_date,
            end_date,
            created_at,
            updated_at,
        }
    }

    public fun new_nft_ownership_data(
        owner: address,
        collection_creator: address,
        shared_percentage: u64,
        parent_token_id: Option<u64>,
        is_root_nft: bool,
        created_timestamp: u64,
        token_name: String,
        token_id: u64,
    ): NFTOwnershipData {
        NFTOwnershipData {
            owner,
            collection_creator,
            shared_percentage,
            parent_token_id,
            is_root_nft,
            created_timestamp,
            token_name,
            token_id,
        }
    }
}