/// Fusumi common code
module fusumi_deployer::common {
    use std::string::String;
    use std::option::Option;
    use std::vector;

    /// Error codes
    const E_CARGO_ALR_EXISTED: u64 = 1;
    const E_NOT_AUTHORIZED: u64 = 2;

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
    public fun not_authorized(): u64 {E_NOT_AUTHORIZED}

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
}