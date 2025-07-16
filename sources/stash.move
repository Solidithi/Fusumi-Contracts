/// Product management logic
module fusumi_deployer::stash {
    use std::error;
    use std::signer;
    use std::string::String;
    use std::option::Option;
    use std::vector;
    use std::table::{Self, Table};
    use aptos_framework::timestamp;
    use fusumi_deployer::dock;

    friend fusumi_deployer::debt_coordinator;

    struct Stash has key {
        cargo: Table<u64, String>,
        next_cargo_id: u64,
        ship_stash: Table<address, vector<u64>>,
    }

    public(friend) fun initialize(account: &signer) {
        move_to(account, Stash {
            cargo: table::new(),
            next_cargo_id: 0,
            ship_stash: table::new(),
        });
    }

    public entry fun load_cargo(){
        
    }
}