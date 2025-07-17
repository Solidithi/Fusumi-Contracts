/// Debt NFT management module
module fusumi_deployer::fusumi_nft_manager {
    use std::error;
    use std::option::{Self, Option};
    use std::vector;
    use std::string::String;
    use fusumi_deployer::common;

    friend fusumi_deployer::debt_coordinator;
    friend fusumi_deployer::debt_root;

    // Global storage for NFT ownership data
    struct GlobalNFTRegistry has key {
        nft_data: vector<common::NFTOwnershipData>,
    }

    /// Initialize the NFT registry
    public(friend) fun initialize(account: &signer) {
        move_to(account, GlobalNFTRegistry {
            nft_data: vector::empty(),
        });
    }

    /// Add new NFT ownership data (friend access)
    public(friend) fun add_nft_data(nft_data: common::NFTOwnershipData) acquires GlobalNFTRegistry {
        let nft_registry = borrow_global_mut<GlobalNFTRegistry>(@fusumi_deployer);
        vector::push_back(&mut nft_registry.nft_data, nft_data);
    }

    /// Find NFT data by owner (friend access)
    public(friend) fun find_nft_data_by_owner(
        owner: address,
        collection_creator: address
    ): Option<common::NFTOwnershipData> acquires GlobalNFTRegistry {
        let nft_registry = borrow_global<GlobalNFTRegistry>(@fusumi_deployer);
        find_nft_data_by_owner_internal(&nft_registry.nft_data, owner, collection_creator)
    }

    /// Update NFT shared percentage by owner and collection_creator (friend access)
    public(friend) fun update_nft_shared_percentage(
        owner: address,
        collection_creator: address,
        new_shared_percentage: u64
    ) acquires GlobalNFTRegistry {
        let nft_registry = borrow_global_mut<GlobalNFTRegistry>(@fusumi_deployer);
        let len = vector::length(&nft_registry.nft_data);
        let i = 0;
        while (i < len) {
            let data = vector::borrow_mut(&mut nft_registry.nft_data, i);
            if (common::nft_owner(data) == owner && common::nft_collection_creator(data) == collection_creator) {
                common::set_nft_shared_percentage(data, new_shared_percentage);
                return;
            };
            i = i + 1;
        };
        abort error::not_found(common::not_nft_owner())
    }

    /// Get NFT shared percentage by owner and collection_creator (friend access)
    public(friend) fun get_nft_shared_percentage(
        owner: address,
        collection_creator: address
    ): u64 acquires GlobalNFTRegistry {
        let nft_registry = borrow_global<GlobalNFTRegistry>(@fusumi_deployer);
        let len = vector::length(&nft_registry.nft_data);
        let i = 0;
        while (i < len) {
            let data = vector::borrow(&nft_registry.nft_data, i);
            if (common::nft_owner(data) == owner && common::nft_collection_creator(data) == collection_creator) {
                return common::nft_shared_percentage(data);
            };
            i = i + 1;
        };
        abort error::not_found(common::not_nft_owner())
    }

    /// Get NFT token id by owner and collection_creator (friend access)
    public(friend) fun get_nft_token_id(
        owner: address,
        collection_creator: address
    ): u64 acquires GlobalNFTRegistry {
        let nft_registry = borrow_global<GlobalNFTRegistry>(@fusumi_deployer);
        let len = vector::length(&nft_registry.nft_data);
        let i = 0;
        while (i < len) {
            let data = vector::borrow(&nft_registry.nft_data, i);
            if (common::nft_owner(data) == owner && common::nft_collection_creator(data) == collection_creator) {
                return common::nft_token_id(data);
            };
            i = i + 1;
        };
        abort error::not_found(common::not_nft_owner())
    }

    /// Helper function to find NFT data by owner
    fun find_nft_data_by_owner_internal(
        nft_data: &vector<common::NFTOwnershipData>,
        owner: address,
        collection_creator: address
    ): Option<common::NFTOwnershipData> {
        let len = vector::length(nft_data);
        let i = 0;
        while (i < len) {
            let data = vector::borrow(nft_data, i);
            if (common::nft_owner(data) == owner && common::nft_collection_creator(data) == collection_creator) {
                return option::some(*data)
            };
            i = i + 1;
        };
        option::none()
    }

    #[view]
    /// View function to get NFT data by owner
    public fun get_nft_data_by_owner(
        owner: address,
        collection_creator: address
    ): (u64, Option<u64>, bool, u64) acquires GlobalNFTRegistry {
        let nft_data_opt = find_nft_data_by_owner(owner, collection_creator);
        if (option::is_some(&nft_data_opt)) {
            let nft_data = option::extract(&mut nft_data_opt);
            (
                common::nft_shared_percentage(&nft_data),
                *common::nft_parent_token_id(&nft_data),
                common::nft_is_root_nft(&nft_data),
                common::nft_token_id(&nft_data)
            )
        } else {
            (0, option::none(), false, 0)
        }
    }

    #[view]
    /// Get all NFT data for debugging/admin purposes
    public fun get_all_nft_data(): vector<common::NFTOwnershipData> acquires GlobalNFTRegistry {
        let nft_registry = borrow_global<GlobalNFTRegistry>(@fusumi_deployer);
        nft_registry.nft_data
    }

    #[test_only]
    /// must init for external testing file as init is private fun
    public fun init_for_testing(account: &signer) {
        initialize(account);
    }
}