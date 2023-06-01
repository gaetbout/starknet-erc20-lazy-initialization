use starknet::ContractAddress;

#[abi]
trait IERC20 {
    #[view]
    fn name() -> felt252;
    #[view]
    fn symbol() -> felt252;
    #[view]
    fn decimals() -> u8;
    #[view]
    fn total_supply() -> u256;
    #[view]
    fn balance_of(account: ContractAddress) -> u256;
    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256;
    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) -> bool;
    #[external]
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    #[external]
    fn approve(spender: ContractAddress, amount: u256) -> bool;
    #[external]
    fn increase_allowance(spender: ContractAddress, added_value: u256) -> bool;
    #[external]
    fn decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool;
}

// For retro compatibility
#[abi]
trait IOLDERC20 {
    #[view]
    fn totalSupply() -> u256;
    #[view]
    fn balanceOf(account: felt252) -> u256;
    #[external]
    fn transferFrom(sender: felt252, recipient: felt252, amount: u256) -> bool;
    #[external]
    fn increaseAllowance(spender: felt252, added_value: u256) -> bool;
    #[external]
    fn decreaseAllowance(spender: felt252, subtracted_value: u256) -> bool;
}

#[contract]
mod ERC20 {
    use super::IERC20;
    use integer::BoundedInt;
    use starknet::{
        ContractAddress, get_caller_address, contract_address::Felt252TryIntoContractAddress
    };
    use traits::TryInto;
    use option::OptionTrait;
    use zeroable::Zeroable;

    const NAME: felt252 = 'Gaetbout';
    const SYMBOL: felt252 = 'GAET';
    const INITIAL_TOKEN_AMOUNT: u256 = 1000000000000000000000; // 1000 * 10^18

    struct Storage {
        _total_supply: u256,
        _balances: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
    }

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}

    impl ERC20 of IERC20 {
        fn name() -> felt252 {
            NAME
        }

        fn symbol() -> felt252 {
                SYMBOL
        }

        fn decimals() -> u8 {
            18_u8
        }

        fn total_supply() -> u256 {
            BoundedInt::max()
        }

        fn balance_of(account: ContractAddress) -> u256 {
            let balance = _balances::read(account);
            if balance == 0 {
                INITIAL_TOKEN_AMOUNT
            } else {
                balance - 1
            }
        }

        fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
            _allowances::read((owner, spender))
        }

        fn transfer(recipient: ContractAddress, amount: u256) -> bool {
            let sender = get_caller_address();
            _transfer(sender, recipient, amount);
            true
        }

        fn transfer_from(
            sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) -> bool {
            let caller = get_caller_address();
            _spend_allowance(sender, caller, amount);
            _transfer(sender, recipient, amount);
            true
        }

        fn approve(spender: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            _approve(caller, spender, amount);
            true
        }

        fn increase_allowance(spender: ContractAddress, added_value: u256) -> bool {
            _increase_allowance(spender, added_value)
        }

        fn decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool {
            _decrease_allowance(spender, subtracted_value)
        }
    }

    #[view]
    fn name() -> felt252 {
        ERC20::name()
    }

    #[view]
    fn symbol() -> felt252 {
        ERC20::symbol()
    }

    #[view]
    fn decimals() -> u8 {
        ERC20::decimals()
    }

    #[view]
    fn total_supply() -> u256 {
        ERC20::total_supply()
    }

    #[view]
    fn totalSupply() -> u256 {
        ERC20::total_supply()
    }

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
        ERC20::balance_of(account)
    }

    #[view]
    fn balanceOf(account: felt252) -> u256 {
        ERC20::balance_of(account.try_into().expect('Non ContractAddress'))
    }

    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        ERC20::allowance(owner, spender)
    }

    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) -> bool {
        ERC20::transfer(recipient, amount)
    }

    #[external]
    fn transfer_from(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool {
        ERC20::transfer_from(sender, recipient, amount)
    }

    #[external]
    fn transferFrom(sender: felt252, recipient: felt252, amount: u256) -> bool {
        ERC20::transfer_from(
            sender.try_into().expect('Non ContractAddress'),
            recipient.try_into().expect('Non ContractAddress'),
            amount
        )
    }

    #[external]
    fn approve(spender: ContractAddress, amount: u256) -> bool {
        ERC20::approve(spender, amount)
    }

    #[external]
    fn increase_allowance(spender: ContractAddress, added_value: u256) -> bool {
        ERC20::increase_allowance(spender, added_value)
    }

    #[external]
    fn increaseAllowance(spender: felt252, added_value: u256) -> bool {
        ERC20::increase_allowance(spender.try_into().expect('Non ContractAddress'), added_value)
    }

    #[external]
    fn decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool {
        ERC20::decrease_allowance(spender, subtracted_value)
    }

    #[external]
    fn decreaseAllowance(spender: felt252, subtracted_value: u256) -> bool {
        ERC20::decrease_allowance(
            spender.try_into().expect('Non ContractAddress'), subtracted_value
        )
    }

    ///
    /// Internals
    ///

    #[internal]
    fn _increase_allowance(spender: ContractAddress, added_value: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) + added_value);
        true
    }

    #[internal]
    fn _decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) - subtracted_value);
        true
    }

    #[internal]
    fn _mint(recipient: ContractAddress, amount: u256) {
        assert(!recipient.is_zero(), 'ERC20: mint to 0');
        _total_supply::write(_total_supply::read() + amount);
        _balances::write(recipient, _balances::read(recipient) + amount);
        Transfer(Zeroable::zero(), recipient, amount);
    }

    #[internal]
    fn _burn(account: ContractAddress, amount: u256) {
        assert(!account.is_zero(), 'ERC20: burn from 0');
        _total_supply::write(_total_supply::read() - amount);
        _balances::write(account, _balances::read(account) - amount);
        Transfer(account, Zeroable::zero(), amount);
    }

    #[internal]
    fn _approve(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        assert(!owner.is_zero(), 'ERC20: approve from 0');
        assert(!spender.is_zero(), 'ERC20: approve to 0');
        _allowances::write((owner, spender), amount);
        Approval(owner, spender, amount);
    }

    #[internal]
    fn _transfer(sender: ContractAddress, recipient: ContractAddress, amount: u256) {
        assert(!sender.is_zero(), 'ERC20: transfer from 0');
        assert(!recipient.is_zero(), 'ERC20: transfer to 0');
        _checkAndSetBalanceFor(sender);
        _checkAndSetBalanceFor(recipient);
        // Done that way to trigger u256_overflow
        let final_balance_sender = ERC20::balance_of(sender) - amount;
        let final_balance_recipient = ERC20::balance_of(sender) + amount;

        // Let's put back the one extra ;)
        _balances::write(sender, final_balance_sender + 1);
        _balances::write(recipient, final_balance_recipient + 1);
        Transfer(sender, recipient, amount);
    }

    #[internal]
    fn _spend_allowance(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        let current_allowance = _allowances::read((owner, spender));
        if current_allowance != BoundedInt::max() {
            _approve(owner, spender, current_allowance - amount);
        }
    }

    #[internal]
    fn _checkAndSetBalanceFor(address: ContractAddress) {
        let actualBalance = _balances::read(address);
        if actualBalance == 0 {
            _mint(address, INITIAL_TOKEN_AMOUNT + 1);
        }
    }
}
