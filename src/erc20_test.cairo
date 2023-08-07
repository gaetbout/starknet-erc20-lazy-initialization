use array::ArrayTrait;
use integer::BoundedInt;
use starknet::{contract_address_const, syscalls::deploy_syscall, testing::set_contract_address};
use result::ResultTrait;
use option::OptionTrait;
use traits::{Into, TryInto};

use lazy::{ERC20, erc20::IERC20Dispatcher, erc20::IERC20DispatcherTrait};

const THOUSAND_TOKENS: u256 = 1000000000000000000000;

fn deploy_erc20() -> IERC20Dispatcher {
    let class_hash = ERC20::TEST_CLASS_HASH.try_into().unwrap();
    let (contract_address, _) = deploy_syscall(class_hash, 0, array![].span(), true).unwrap();
    IERC20Dispatcher { contract_address }
}

fn actual_balance(address: felt252) -> u256 {
    let list_storage_state = ERC20::unsafe_new_contract_state();
    ERC20::PrivateTrait::_actual_balance(@list_storage_state, address.try_into().unwrap())
}
#[test]
#[available_gas(20000000)]
fn balance_of() {
    let erc20 = deploy_erc20();

    let fake_balance = erc20.balance_of(42.try_into().unwrap());
    assert(fake_balance == THOUSAND_TOKENS, 'Fake balance wrong');
    assert(actual_balance(42) == 0, 'Actual balance wrong');
}
#[test]
#[available_gas(20000000)]
fn total_supply() {
    let erc20 = deploy_erc20();

    let max_u256 = BoundedInt::max();
    assert(erc20.total_supply() == max_u256, 'total_supply should be max');
// assert(erc20.totalSupply() == max_u256, 'total_supply should be max');
}

#[available_gas(20000000)]
#[test]
fn test_transfer() {
    let erc20 = deploy_erc20();

    let fake_balance_42 = erc20.balance_of(42.try_into().unwrap());
    assert(fake_balance_42 == THOUSAND_TOKENS, 'Fake before balance 42 wrong');

    assert(actual_balance(42) == 0, 'Actual before balance 42 wrong');
    let fake_balance_21 = erc20.balance_of(21.try_into().unwrap());
    assert(fake_balance_21 == THOUSAND_TOKENS, 'Fake before balance 21 wrong');
    assert(actual_balance(21) == 0, 'Actual before balance 21 wrong');

    set_contract_address(42.try_into().unwrap());
    erc20.transfer(21.try_into().unwrap(), 1);

    let fake_balance_42 = erc20.balance_of(42.try_into().unwrap());
    assert(fake_balance_42 == THOUSAND_TOKENS - 1, 'Fake balance 42 wrong');
    // assert(actual_balance(42) == THOUSAND_TOKENS, 'Actual balance 42 wrong');
    let fake_balance_21 = erc20.balance_of(21.try_into().unwrap());
    assert(fake_balance_21 == THOUSAND_TOKENS + 1, 'Fake balance 21 wrong');
//assert(actual_balance(21) == THOUSAND_TOKENS + 2, 'Actual balance 21 wrong');
}
// #[test]
// #[available_gas(20000000)]
// fn test_transfer_retro() {
//     let erc20 = deploy_erc20();

//     let fake_balance_42 = erc20.balanceOf(42);
//     assert(fake_balance_42 == THOUSAND_TOKENS, 'Fake before balance 42 wrong');
//     assert(actual_balance(42) == 0, 'Actual before balance 42 wrong');
//     let fake_balance_21 = erc20.balanceOf(21);
//     assert(fake_balance_21 == THOUSAND_TOKENS, 'Fake before balance 21 wrong');
//     assert(actual_balance(21) == 0, 'Actual before balance 21 wrong');

//     set_contract_address(42.try_into().unwrap());
//     erc20.transfer(21.try_into().unwrap(), 1);

//     let fake_balance_42 = erc20.balanceOf(42);
//     assert(fake_balance_42 == THOUSAND_TOKENS - 1, 'Fake balance 42 wrong');
//     assert(actual_balance(42) == THOUSAND_TOKENS, 'Actual balance 42 wrong');
//     let fake_balance_21 = erc20.balanceOf(21);
//     assert(fake_balance_21 == THOUSAND_TOKENS + 1, 'Fake balance 21 wrong');
//     assert(actual_balance(21) == THOUSAND_TOKENS + 1 + 1, 'Actual balance 21 wrong');
// }

#[test]
#[available_gas(20000000)]
fn test_transfer_100() {
    let erc20 = deploy_erc20();

    let fake_balance_42 = erc20.balance_of(42.try_into().unwrap());
    assert(fake_balance_42 == THOUSAND_TOKENS, 'Fake before balance 42 wrong');
    assert(actual_balance(42) == 0, 'Actual before balance 42 wrong');
    let fake_balance_21 = erc20.balance_of(21.try_into().unwrap());
    assert(fake_balance_21 == THOUSAND_TOKENS, 'Fake before balance 21 wrong');
    assert(actual_balance(21) == 0, 'Actual before balance 21 wrong');

    set_contract_address(42.try_into().unwrap());
    erc20.transfer(21.try_into().unwrap(), 100);

    let fake_balance_42 = erc20.balance_of(42.try_into().unwrap());
    assert(fake_balance_42 == THOUSAND_TOKENS - 100, 'Fake balance 42 wrong');
    // assert(actual_balance(42) == THOUSAND_TOKENS - 99, 'Actual balance 42 wrong');
    let fake_balance_21 = erc20.balance_of(21.try_into().unwrap());
    assert(fake_balance_21 == THOUSAND_TOKENS + 100, 'Fake balance 21 wrong');
// assert(actual_balance(21) == THOUSAND_TOKENS + 100 + 1, 'Actual balance 21 wrong');
}

#[test]
#[available_gas(20000000)]
fn test_transfer_all() {
    let erc20 = deploy_erc20();

    set_contract_address(42.try_into().unwrap());
    erc20.transfer(21.try_into().unwrap(), THOUSAND_TOKENS);

    let fake_balance_42 = erc20.balance_of(42.try_into().unwrap());
    assert(fake_balance_42 == 0, 'Fake balance 42 wrong');
// assert(actual_balance(42) == 1, 'Actual balance 42 wrong');
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('u256_sub Overflow', 'ENTRYPOINT_FAILED'))]
fn test_transfer_all_and_transfer_again() {
    let erc20 = deploy_erc20();

    set_contract_address(42.try_into().unwrap());
    erc20.transfer(21.try_into().unwrap(), THOUSAND_TOKENS);

    erc20.transfer(21.try_into().unwrap(), 1);
}

