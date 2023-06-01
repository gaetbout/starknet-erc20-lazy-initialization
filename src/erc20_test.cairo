use starknet::contract_address_const;
use starknet::testing::{set_block_timestamp, set_caller_address};
use integer::u256_overflow_sub;
use traits::Into;
use traits::TIntoT;

use lazy::ERC20;

const TEST_ADDRESS_1: felt252 = 21;
const TEST_ADDRESS_2: felt252 = 42;
const THOUSAND_TOKENS: u256 = 1000000000000000000000;
const ONE_TOKEN: felt252 = 1000000000000000000;
// set_caller_address(contract_address_const::<42>());

#[test]
#[available_gas(2000000)]
fn balance_of() {
    let fake_balance = ERC20::balance_of(contract_address_const::<42>());
    assert(fake_balance == THOUSAND_TOKENS, 'Fake balance wrong');
    let actual_balance = ERC20::_balances::read(contract_address_const::<42>());
    assert(actual_balance == 0, 'Actual balance wrong');
}

#[test]
#[available_gas(2000000)]
fn t() {
    let a: u128 = 12; 
    let b: u256 = a.into();
}


#[test]
#[available_gas(2000000)]
fn total_supply() {
    let (max_u256, _) = u256_overflow_sub(0,1);
    assert(ERC20::total_supply() == max_u256, 'total_supply should be max');
    assert(ERC20::totalSupply() == max_u256, 'total_supply should be max');
}

#[available_gas(2000000)]
#[test]
fn test_transfer() {
    let fake_balance_42 = ERC20::balance_of(contract_address_const::<42>());
    assert(fake_balance_42 == THOUSAND_TOKENS, 'Fake before balance 42 wrong');
    let actual_balance_42 = ERC20::_balances::read(contract_address_const::<42>());
    assert(actual_balance_42 == 0, 'Actual before balance 42 wrong');
    let fake_balance_21 = ERC20::balance_of(contract_address_const::<21>());
    assert(fake_balance_21 == THOUSAND_TOKENS, 'Fake before balance 21 wrong');
    let actual_balance_21 = ERC20::_balances::read(contract_address_const::<21>());
    assert(actual_balance_21 == 0, 'Actual before balance 21 wrong');

    set_caller_address(contract_address_const::<42>());
    ERC20::transfer(contract_address_const::<21>(), 1);

    let fake_balance_42 = ERC20::balance_of(contract_address_const::<42>());
    assert(fake_balance_42 == THOUSAND_TOKENS - 1, 'Fake balance 42 wrong');
    let actual_balance_42 = ERC20::_balances::read(contract_address_const::<42>());
    assert(actual_balance_42 == THOUSAND_TOKENS, 'Actual balance 42 wrong');
    let fake_balance_21 = ERC20::balance_of(contract_address_const::<21>());
    assert(fake_balance_21 == THOUSAND_TOKENS + 1, 'Fake balance 21 wrong');
    let actual_balance_21 = ERC20::_balances::read(contract_address_const::<21>());
    assert(actual_balance_21 == THOUSAND_TOKENS + 2, 'Actual balance 21 wrong');
}


#[test]
#[available_gas(2000000)]
fn test_transfer_retro() {
    let fake_balance_42 = ERC20::balanceOf(42);
    assert(fake_balance_42 == THOUSAND_TOKENS, 'Fake before balance 42 wrong');
    let actual_balance_42 = ERC20::_balances::read(contract_address_const::<42>());
    assert(actual_balance_42 == 0, 'Actual before balance 42 wrong');
    let fake_balance_21 = ERC20::balanceOf(21);
    assert(fake_balance_21 == THOUSAND_TOKENS, 'Fake before balance 21 wrong');
    let actual_balance_21 = ERC20::_balances::read(contract_address_const::<21>());
    assert(actual_balance_21 == 0, 'Actual before balance 21 wrong');

    set_caller_address(contract_address_const::<42>());
    ERC20::transfer(contract_address_const::<21>(), 1);

    let fake_balance_42 = ERC20::balanceOf(42);
    assert(fake_balance_42 == THOUSAND_TOKENS - 1, 'Fake balance 42 wrong');
    let actual_balance_42 = ERC20::_balances::read(contract_address_const::<42>());
    assert(actual_balance_42 == THOUSAND_TOKENS, 'Actual balance 42 wrong');
    let fake_balance_21 = ERC20::balanceOf(21);
    assert(fake_balance_21 == THOUSAND_TOKENS + 1, 'Fake balance 21 wrong');
    let actual_balance_21 = ERC20::_balances::read(contract_address_const::<21>());
    assert(actual_balance_21 == THOUSAND_TOKENS + 1 + 1, 'Actual balance 21 wrong');
}


#[test]
#[available_gas(2000000)]
fn test_transfer_100() {
    let fake_balance_42 = ERC20::balance_of(contract_address_const::<42>());
    assert(fake_balance_42 == THOUSAND_TOKENS, 'Fake before balance 42 wrong');
    let actual_balance_42 = ERC20::_balances::read(contract_address_const::<42>());
    assert(actual_balance_42 == 0, 'Actual before balance 42 wrong');
    let fake_balance_21 = ERC20::balance_of(contract_address_const::<21>());
    assert(fake_balance_21 == THOUSAND_TOKENS, 'Fake before balance 21 wrong');
    let actual_balance_21 = ERC20::_balances::read(contract_address_const::<21>());
    assert(actual_balance_21 == 0, 'Actual before balance 21 wrong');

    set_caller_address(contract_address_const::<42>());
    ERC20::transfer(contract_address_const::<21>(), 100);

    let fake_balance_42 = ERC20::balance_of(contract_address_const::<42>());
    assert(fake_balance_42 == THOUSAND_TOKENS - 100, 'Fake balance 42 wrong');
    let actual_balance_42 = ERC20::_balances::read(contract_address_const::<42>());
    assert(actual_balance_42 == THOUSAND_TOKENS - 99, 'Actual balance 42 wrong');
    let fake_balance_21 = ERC20::balance_of(contract_address_const::<21>());
    assert(fake_balance_21 == THOUSAND_TOKENS + 100, 'Fake balance 21 wrong');
    let actual_balance_21 = ERC20::_balances::read(contract_address_const::<21>());
    assert(actual_balance_21 == THOUSAND_TOKENS + 100 + 1, 'Actual balance 21 wrong');
}

#[test]
#[available_gas(2000000)]
fn test_transfer_all() {
    set_caller_address(contract_address_const::<42>());
    ERC20::transfer(contract_address_const::<21>(), THOUSAND_TOKENS);

    let fake_balance_42 = ERC20::balance_of(contract_address_const::<42>());
    assert(fake_balance_42 == 0, 'Fake balance 42 wrong');
    let actual_balance_42 = ERC20::_balances::read(contract_address_const::<42>());
    assert(actual_balance_42 == 1, 'Actual balance 42 wrong');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('u256_sub Overflow', ))]
fn test_transfer_all_and_transfer_again() {
    set_caller_address(contract_address_const::<42>());
    ERC20::transfer(contract_address_const::<21>(), THOUSAND_TOKENS);

    ERC20::transfer(contract_address_const::<21>(), 1);
}


