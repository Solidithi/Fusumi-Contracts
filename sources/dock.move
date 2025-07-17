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
        ship_address: address,
        moderator: address,
        timestamp: u64,
    }

    #[event]
    struct ShipDeparted has drop, store {
        ship_address: address,
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
        
    ) acquires Dock {
        
    }

    public entry fun departing_ship(
        
    ) acquires Dock {
        
    }
}