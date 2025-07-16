/// Business management logic
module fusumi_deployer::dock{
    use std::error;
    use std::signer;
    use std::vector;
    use aptos_framework::event;
    use aptos_framework::timestamp;
    
    friend fusumi_deployer::debt_coordinator;

    struct Dock has key {
        ships: vector<address>,
        moderator: address,
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