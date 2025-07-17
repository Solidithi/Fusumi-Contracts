/// Fusumi common code
module fusumi_deployer::common {
    use std::string::String;
    use std::option::Option;
    use std::vector;

    /// Error codes

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

}