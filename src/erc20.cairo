#[contract]
mod ERC20 {
    use zeroable::Zeroable;
    use core::traits::Into;
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use starknet::ContractAddress;
    use starknet::ContractAddressZeroable;

    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: u256,
        balances: LegacyMap::<ContractAddress, u256>,
        allowances: LegacyMap::<(ContractAddress, ContractAddress), u256>,
    }

    const NAME: felt252  = 'Gaetbout';
    const SYMBOL: felt252  = 'GAET';
    const DECIMALS: u8  = 18_u8;
    const INITIAL_TOKEN_AMOUNT: felt252  = 100000000000000000000;  // 100 * 10^18

    fn initial_token_amount() -> u256 {
        u256 {low: 100000000000000000000_u128, high: 0_u128}
    }

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}

    #[constructor]
    fn constructor() { 
        let recipient = get_caller_address();
        name::write(NAME);
        symbol::write(SYMBOL);
        decimals::write(DECIMALS);
        assert(recipient.is_zero(), 'ERC20: mint to the 0 address');
        total_supply::write(initial_token_amount());
        balances::write(recipient, initial_token_amount());
        Transfer(contract_address_const::<0>(), recipient, initial_token_amount());
    }

    #[view]
    fn get_name() -> felt252 {
        name::read()
    }

    #[view]
    fn get_symbol() -> felt252 {
        symbol::read()
    }

    #[view]
    fn get_decimals() -> u8 {
        decimals::read()
    }

    #[view]
    fn get_total_supply() -> u256 {
        total_supply::read()
    }

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
        let balance = balances::read(account);
        if balance == 0.into() {
            initial_token_amount()
        } else {
            balance - 1.into()
        }
    }

    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        allowances::read((owner, spender))
    }

    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) {
        let sender = get_caller_address();
        transfer_helper(sender, recipient, amount);
    }

    #[external]
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) {
        let caller = get_caller_address();
        spend_allowance(sender, caller, amount);
        transfer_helper(sender, recipient, amount);
    }

    #[external]
    fn approve(spender: ContractAddress, amount: u256) {
        let caller = get_caller_address();
        approve_helper(caller, spender, amount);
    }

    #[external]
    fn increase_allowance(spender: ContractAddress, added_value: u256) {
        let caller = get_caller_address();
        approve_helper(caller, spender, allowances::read((caller, spender)) + added_value);
    }

    #[external]
    fn decrease_allowance(spender: ContractAddress, subtracted_value: u256) {
        let caller = get_caller_address();
        approve_helper(caller, spender, allowances::read((caller, spender)) - subtracted_value);
    }

    fn transfer_helper(sender: ContractAddress, recipient: ContractAddress, amount: u256) {
        assert(!sender.is_zero(), 'ERC20: transfer from 0');
        assert(!recipient.is_zero(), 'ERC20: transfer to 0');
        check_and_set_balance_for(sender);
        check_and_set_balance_for(recipient);
        balances::write(sender, balances::read(sender) - amount);
        balances::write(recipient, balances::read(recipient) + amount);
        Transfer(sender, recipient, amount);
    }

    fn spend_allowance(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        let current_allowance = allowances::read((owner, spender));
        let ONES_MASK = 0xffffffffffffffffffffffffffffffff_u128;
        let is_unlimited_allowance =
            current_allowance.low == ONES_MASK & current_allowance.high == ONES_MASK;
        if !is_unlimited_allowance {
            approve_helper(owner, spender, current_allowance - amount);
        }
    }

    fn approve_helper(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        assert(!spender.is_zero(), 'ERC20: approve from 0');
        allowances::write((owner, spender), amount);
        Approval(owner, spender, amount);
    }

    fn check_and_set_balance_for(address: ContractAddress) {
        if balances::read(address) == 0.into() {
            let amountToTransfer = initial_token_amount() + 1.into();
            balances::write(address, amountToTransfer);
        }
    }
}
