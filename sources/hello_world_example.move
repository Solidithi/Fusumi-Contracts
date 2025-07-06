module ye_contracts::hello_world {
    use std::string;
    use aptos_framework::event;

    /// Event emitted when a greeting is created
    struct GreetingEvent has drop, store {
        greeting: string::String,
        timestamp: u64,
    }

    /// Resource to store greeting data
    struct GreetingHolder has key {
        greeting: string::String,
        counter: u64,
    }

    /// Initialize the greeting holder for an account
    public entry fun initialize_greeting(account: &signer) {
        let greeting_holder = GreetingHolder {
            greeting: string::utf8(b"Hello, Aptos Move!"),
            counter: 0,
        };
        move_to(account, greeting_holder);
    }

    /// Update the greeting message
    public entry fun update_greeting(
        account: &signer,
        new_greeting: string::String,
    ) acquires GreetingHolder {
        let account_addr = std::signer::address_of(account);
        let greeting_holder = borrow_global_mut<GreetingHolder>(account_addr);
        
        greeting_holder.greeting = new_greeting;
        greeting_holder.counter = greeting_holder.counter + 1;

        // Emit event
        event::emit(GreetingEvent {
            greeting: new_greeting,
            timestamp: aptos_framework::timestamp::now_seconds(),
        });
    }

    /// Get the current greeting
    #[view]
    public fun get_greeting(account_addr: address): string::String acquires GreetingHolder {
        let greeting_holder = borrow_global<GreetingHolder>(account_addr);
        greeting_holder.greeting
    }

    /// Get the greeting counter
    #[view]
    public fun get_counter(account_addr: address): u64 acquires GreetingHolder {
        let greeting_holder = borrow_global<GreetingHolder>(account_addr);
        greeting_holder.counter
    }

    /// Check if an account has initialized greeting
    #[view]
    public fun has_greeting(account_addr: address): bool {
        exists<GreetingHolder>(account_addr)
    }

    #[test_only]
    use aptos_framework::account;

    #[test(account = @0x1)]
    public entry fun test_greeting(account: signer) acquires GreetingHolder {
        // Initialize the greeting
        initialize_greeting(&account);
        
        // Check if greeting exists
        let account_addr = std::signer::address_of(&account);
        assert!(has_greeting(account_addr), 1);
        
        // Get initial greeting
        let initial_greeting = get_greeting(account_addr);
        assert!(initial_greeting == string::utf8(b"Hello, Aptos Move!"), 2);
        
        // Update greeting
        let new_greeting = string::utf8(b"Hello, Updated World!");
        update_greeting(&account, new_greeting);
        
        // Verify update
        let updated_greeting = get_greeting(account_addr);
        assert!(updated_greeting == new_greeting, 3);
        
        // Check counter
        let counter = get_counter(account_addr);
        assert!(counter == 1, 4);
    }
}
