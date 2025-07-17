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
    friend fusumi_deployer:debt_root;

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
        assert!(dock.moderator == moderator_addr, error::permission_denied(common::not_moderator()));
        assert!(vector::contains(&dock.ships, &ship_imo), error::not_found(common::ship_not_found()));
        vector::remove(&mut dock.ships, &ship_imo);
        event::emit(ShipDeparted {
            ship_imo,
            moderator: moderator_addr,
            timestamp: timestamp::now_seconds(),
        });
    }

}