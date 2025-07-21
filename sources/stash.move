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
        cargo: Table<u64, common::Cargo>,
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
        cargo_type: String,
        price: u64,
        unit_of_measure: String,
        description: Option<String>,
        images: vector<String>,
        start_date: u64,
        end_date: u64,
    ) acquires Stash {
        let ship_imo = signer::address_of(ship);
        dock::verify_ship_authorization(ship_imo);

        let cargo_registry = borrow_global_mut<Stash>(@fusumi_deployer);
        let cargo_id = cargo_registry.next_cargo_id;
        cargo_registry.next_cargo_id += 1;
        assert!(
            !table::contains(&cargo_registry.cargo, cargo_id),
            error::already_exists(common::cargo_alr_existed())
        );

        let cargo = common::new_cargo(
            cargo_id,
            ship_imo,
            cargo_name,
            cargo_type,
            price,
            unit_of_measure,
            description,
            images,
            start_date,
            end_date,
            timestamp::now_seconds(),
            timestamp::now_seconds(),
        );
        table::add(&mut cargo_registry.cargo, cargo_id, cargo);

        if(table::contains(&cargo_registry.ship_stash, ship_imo)) {
            let vec_ref = table::borrow_mut(&mut cargo_registry.ship_stash, ship_imo);
            vector::push_back(vec_ref, cargo_id);
        } else {
            let vec = vector::empty<u64>();
            vector::push_back(&mut vec, cargo_id);
            table::add(&mut cargo_registry.ship_stash, ship_imo, vec);
        }
    }

    /// get product by id
    public(friend) fun get_cargo(cargo_id: u64): common::Cargo acquires Stash {
        let cargo_registry = borrow_global<Stash>(@fusumi_deployer);
        assert!(
            table::contains(&cargo_registry.cargo, cargo_id), 
            error::not_found(common::cargo_not_found())
        );
        *table::borrow(&cargo_registry.cargo, cargo_id)
    }

    /// verify product belong to a business
    public fun verify_cargo_ownership(cargo_id: u64, ship_imo: address) acquires Stash {
        let cargo = get_cargo(cargo_id);
        assert!
        (
            common::cargo_ship_imo(&cargo) == ship_imo,
            error::permission_denied(common::not_authorized())    
        );
    }

    /// verify cargo existed
    public(friend) fun cargo_existed(cargo_id: u64): bool acquires Stash {
        let cargo_registry = borrow_global_mut<Stash>(@fusumi_deployer);
        table::contains(&cargo_registry.cargo, cargo_id)
    }

    #[view]
    /// getter for cargo details
    public fun get_cargo_info(cargo_id: u64):
    (address, String, Option<String>, u64, String, String, vector<String>, u64, u64, u64, u64)
    acquires Stash 
    {
        let cargo = get_cargo(cargo_id);
        (
            common::cargo_ship_imo(&cargo),
            common::cargo_name(&cargo),
            common::cargo_description(&cargo),
            common::cargo_price(&cargo),
            common::cargo_type(&cargo),
            common::cargo_unit_of_measure(&cargo),
            common::cargo_images(&cargo),
            common::cargo_start_date(&cargo),
            common::cargo_end_date(&cargo),
            common::cargo_created_at(&cargo),
            common::cargo_updated_at(&cargo)
        )
    }

    #[view]
    /// check for cargo existence
    public fun cargo_exists_view(cargo_id: u64): bool acquires Stash{
        cargo_existed(cargo_id)
    }

    #[view]
    /// get all products that provide by a business
    public fun get_cargos_by_ship(ship_imo: address): vector<u64> acquires Stash {
        let cargo_registry = borrow_global<Stash>(@fusumi_deployer);
        if(table::contains(&cargo_registry.ship_stash, ship_imo)){
            *table::borrow(&cargo_registry.ship_stash, ship_imo)
        } else {
            vector::empty<u64>()
        }
    }

    #[test_only]
    /// must init for external testing file as init is private fun
    public fun init_for_testing(account: &signer){
        initialize(account);
    }
}