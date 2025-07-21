/// Business management logic
module fusumi_deployer::dock{
    use std::error;
    use std::signer;
    use std::vector;
    use aptos_framework::event;
    use aptos_framework::timestamp;
    use fusumi_deployer::common;
    
    friend fusumi_deployer::debt_coordinator;
    friend fusumi_deployer::stash;
    friend fusumi_deployer::debt_root;

    struct Dock has key {
        ships: vector<address>,
        moderator: address,
    }

    #[event]
    struct ShipAnchored has drop, store {
        ship_imo: address,
        moderator: address,
        timestamp: u64,
    }

    #[event]
    struct ShipDeparted has drop, store {
        ship_imo: address,
        moderator: address,
        timestamp: u64,
    }

    public(friend) fun initialize(account: &signer) {
        let moderator = signer::address_of(account);
        move_to(account, Dock {
            ships: vector::empty(),
            moderator,
        });
    }

    public entry fun anchoring_ship(
        moderator: &signer,
        ship_imo: address
    ) acquires Dock {
        let moderator_addr = signer::address_of(moderator);
        let dock = borrow_global_mut<Dock>(@fusumi_deployer);
        assert!(dock.moderator == moderator_addr, error::permission_denied(common::not_moderator()));
        assert!(!vector::contains(&dock.ships, &ship_imo), error::already_exists(common::ship_already_exists()));
        vector::push_back(&mut dock.ships, ship_imo);
        event::emit(ShipAnchored {
            ship_imo,
            moderator: moderator_addr,
            timestamp: timestamp::now_seconds(),
        });
    }

    public entry fun departing_ship(
        moderator: &signer,
        ship_imo: address
    ) acquires Dock {
        let moderator_addr = signer::address_of(moderator);
        let dock = borrow_global_mut<Dock>(@fusumi_deployer);
        assert!
        (
            dock.moderator == moderator_addr,
            error::permission_denied(common::not_moderator())
        );
        let (found, index) = vector::index_of(&dock.ships, &ship_imo);
        assert!(found, error::not_found(common::ship_not_found()));
        vector::remove(&mut dock.ships, index);
        event::emit(ShipDeparted {
            ship_imo,
            moderator: moderator_addr,
            timestamp: timestamp::now_seconds(),
        });
    }

    public(friend) fun is_ship_anchored(ship_imo: address): bool acquires Dock {
        let dock = borrow_global<Dock>(@fusumi_deployer);
        vector::contains(&dock.ships, &ship_imo)
    }

    /// Businesses can in chare of adding their own product, this function will be called over stash
    public(friend) fun verify_ship_authorization(ship_imo: address) acquires Dock {
        assert!
        (
            is_ship_anchored(ship_imo), 
            error::permission_denied(common::not_authorized())
        );
    }

    #[view]
    public fun is_ship_anchored_view(ship_imo: address): bool acquires Dock {
        is_ship_anchored(ship_imo)
    }

    #[view]
    /// Get all registered businesses
    public fun get_all_ships(): vector<address> acquires Dock {
        let dock = borrow_global<Dock>(@fusumi_deployer);
        dock.ships
    }

    #[view]
    public fun get_moderator(): address acquires Dock {
        let dock = borrow_global<Dock>(@fusumi_deployer);
        dock.moderator
    }

    #[test_only]
    /// must init for external testing file as init is private fun
    public fun init_for_testing(account: &signer) {
        initialize(account);
    }

    #[view]
    public fun is_initialized(): bool {
        exists<Dock>(@fusumi_deployer)
    }
}