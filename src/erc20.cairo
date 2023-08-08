use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState, ) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;

    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
    fn increase_allowance(
        ref self: TContractState, spender: ContractAddress, added_value: u256
    ) -> bool;
    fn decrease_allowance(
        ref self: TContractState, spender: ContractAddress, subtracted_value: u256
    ) -> bool;
}

// For retro compatibility
#[starknet::interface]
trait IOLDERC20<TContractState> {
    fn totalSupply(self: @TContractState, ) -> u256;
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;

    fn transferFrom(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn increaseAllowance(
        ref self: TContractState, spender: ContractAddress, added_value: u256
    ) -> bool;
    fn decreaseAllowance(
        ref self: TContractState, spender: ContractAddress, subtracted_value: u256
    ) -> bool;
}

#[starknet::contract]
mod ERC20 {
    use super::{IERC20, IOLDERC20};
    use integer::BoundedInt;
    use starknet::{ContractAddress, get_caller_address};
    use zeroable::Zeroable;

    const NAME: felt252 = 'Sylve';
    const SYMBOL: felt252 = 'SYLVE';
    const INITIAL_TOKEN_AMOUNT: u256 = 42000000000000000000000; // 42000 * 10^18

    #[storage]
    struct Storage {
        _balances: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        value: u256
    }
    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        spender: ContractAddress,
        value: u256
    }

    #[external(v0)]
    impl ERC20 of IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            NAME
        }

        fn symbol(self: @ContractState) -> felt252 {
            SYMBOL
        }

        fn decimals(self: @ContractState) -> u8 {
            18
        }

        fn total_supply(self: @ContractState, ) -> u256 {
            BoundedInt::max()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            let balance = self._balances.read(account);
            if balance == 0 {
                INITIAL_TOKEN_AMOUNT
            } else {
                balance - 1
            }
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self._allowances.read((owner, spender))
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let sender = get_caller_address();
            self._transfer(sender, recipient, amount);
            true
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            self._spend_allowance(sender, caller, amount);
            self._transfer(sender, recipient, amount);
            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            self._approve(caller, spender, amount);
            true
        }
        fn increase_allowance(
            ref self: ContractState, spender: ContractAddress, added_value: u256
        ) -> bool {
            self._increase_allowance(spender, added_value)
        }

        fn decrease_allowance(
            ref self: ContractState, spender: ContractAddress, subtracted_value: u256
        ) -> bool {
            self._decrease_allowance(spender, subtracted_value)
        }
    }

    #[external(v0)]
    impl OLDERC20 of IOLDERC20<ContractState> {
        fn totalSupply(self: @ContractState, ) -> u256 {
            self.total_supply()
        }
        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            self.balance_of(account)
        }

        fn transferFrom(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            self.transfer_from(sender, recipient, amount)
        }

        fn increaseAllowance(
            ref self: ContractState, spender: ContractAddress, added_value: u256
        ) -> bool {
            self.increase_allowance(spender, added_value)
        }

        fn decreaseAllowance(
            ref self: ContractState, spender: ContractAddress, subtracted_value: u256
        ) -> bool {
            self.decrease_allowance(spender, subtracted_value)
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn _actual_balance(self: @ContractState, address: ContractAddress) -> u256 {
            self._balances.read(address)
        }

        fn _increase_allowance(
            ref self: ContractState, spender: ContractAddress, added_value: u256
        ) -> bool {
            let caller = get_caller_address();
            self._approve(caller, spender, self._allowances.read((caller, spender)) + added_value);
            true
        }

        fn _decrease_allowance(
            ref self: ContractState, spender: ContractAddress, subtracted_value: u256
        ) -> bool {
            let caller = get_caller_address();
            self
                ._approve(
                    caller, spender, self._allowances.read((caller, spender)) - subtracted_value
                );
            true
        }

        fn _burn(ref self: ContractState, account: ContractAddress, amount: u256) {
            assert(!account.is_zero(), 'ERC20: burn from 0');
            self._balances.write(account, self._balances.read(account) - amount);
            self.emit(Transfer { from: account, to: Zeroable::zero(), value: amount });
        }

        fn _approve(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            assert(!owner.is_zero(), 'ERC20: approve from 0');
            assert(!spender.is_zero(), 'ERC20: approve to 0');
            self._allowances.write((owner, spender), amount);
            self.emit(Approval { owner, spender, value: amount });
        }

        fn _transfer(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) {
            assert(!sender.is_zero(), 'ERC20: transfer from 0');
            assert(!recipient.is_zero(), 'ERC20: transfer to 0');
            self._checkAndSetBalanceFor(sender);
            self._checkAndSetBalanceFor(recipient);
            // Done that way to trigger u256_overflow
            let final_balance_sender = self.balance_of(sender) - amount;
            let final_balance_recipient = self.balance_of(recipient) + amount;

            self._balances.write(sender, final_balance_sender + 1);
            self._balances.write(recipient, final_balance_recipient + 1);
            self.emit(Transfer { from: sender, to: recipient, value: amount });
        }

        fn _spend_allowance(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            let current_allowance = self._allowances.read((owner, spender));
            if current_allowance != BoundedInt::max() {
                self._approve(owner, spender, current_allowance - amount);
            }
        }

        fn _checkAndSetBalanceFor(ref self: ContractState, address: ContractAddress) {
            let actualBalance = self._balances.read(address);
            if actualBalance.is_zero() {
                let amount = INITIAL_TOKEN_AMOUNT + 1;
                self._balances.write(address, amount);
                self.emit(Transfer { from: Zeroable::zero(), to: address, value: amount });
            }
        }
    }
}
