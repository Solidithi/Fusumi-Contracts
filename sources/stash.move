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
    use fusumi_deployer::common;

    friend fusumi_deployer::debt_coordinator;
    friend fusumi_deployer::debt_root;

    struct Stash has key {
        cargo: Table<u64, common:Cargo>,
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
    ){
        let ship_imo = signer::address_of(ship);

        let cargo_registry = borrow_global_mut<Stash>(@fusumi_deployer);
        let cargo_id = cargo_registry.next_cargo_id;
        cargo_registry.next_cargo_id += 1;
        assert!(!table::contains(&cargo_registry.cargo, cargo_id),
        error::already_exists(common::cargo_alr_existed()));

        let cargo = common::Cargo {
            id: cargo_id,
            ship_imo,
            cargo_name,
            cargo_type,
            price,
            unit_of_measure,
            description,
            images,
            start_date,
            end_date,
            created_at: timestamp::now(),
            updated_at: timestamp::now(),
        };
        table::add(&mut cargo_registry.cargo, cargo_id, cargo);

        if(table::contains(&cargo_registry.ship_stash, ship_imo)) {
            let vec_ref = table::borrow_mut(&mut cargo_registry.ship_stash, ship_imo);
            vector::push_back(vec_ref, cargo_id);
        } else {
            let vec_ref = vector::empty<u64>();
            vector::push_back(&mut vec, product_id);
            table::add(&mut cargo_registry.ship_stash, ship_imo, vec);
        }
    }
}