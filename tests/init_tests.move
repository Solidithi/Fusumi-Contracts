#[test_only]
module fusumi_deployer::init_tests {
    use fusumi_deployer::dock;

    #[test(fusumi_deployer = @fusumi_deployer)]
    fun test_dock_initialization(fusumi_deployer: &signer) {
        dock::init_for_testing(fusumi_deployer);
        assert!(dock::is_initialized(), 0);
    }
}
