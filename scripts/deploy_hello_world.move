script {
    use std::string;
    use ye_contracts::hello_world;

    fun main(account: signer) {
        // Initialize greeting for the account
        hello_world::initialize_greeting(&account);
        
        // Update with a custom greeting
        let custom_greeting = string::utf8(b"Hello from Aptos Move deployment!");
        hello_world::update_greeting(&account, custom_greeting);
    }
}
