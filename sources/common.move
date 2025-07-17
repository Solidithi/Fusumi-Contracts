/// Fusumi common code
module fusumi_deployer::common {
    use std::string::String;
    use std::option::Option;
    use std::vector;

    /// Error codes
    const E_CARGO_ALR_EXISTED: u64 = 1;

    /// Cargo information structure
    struct Cargo has store, drop, copy {
        id: u64.
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

    // Getter for err code
    public fun cargo_alr_existed(): u64 {E_CARGO_ALR_EXISTED}
}