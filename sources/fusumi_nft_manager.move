/// Debt NFT management module
module fusumi_deployer::fusumi_market_manager {
    use std::error;
    use std::option::{Self, Option};
    use std::vector;
    use std::string::String;

    friend fusumi_deployer::debt_coordinator;
    friend fusumi_deployer::debt_root;

    // Global storage for NFT ownership data
    struct GlobalNFTRegistry has key {
        
    }

    /// Initialize the NFT registry
    public(friend) fun initialize(account: &signer) {
        move_to(account, GlobalNFTRegistry {
            nft_data: vector::empty(),
        });
    }

    /// Add new NFT ownership data (friend access)
    public(friend) fun add_nft_data() {

    }

    /// Find NFT data by owner (friend access)
    public(friend) fun find_nft_data_by_owner() {

    }
}