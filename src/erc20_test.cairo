use array::ArrayTrait;
use integer::BoundedInt;
use starknet::{
    contract_address_const, syscalls::deploy_syscall, testing::set_contract_address, ContractAddress
};
use result::ResultTrait;
use option::OptionTrait;
use traits::{Into, TryInto};

use lazy::{
    ERC20,
    erc20::{IERC20Dispatcher, IERC20DispatcherTrait, IOLDERC20Dispatcher, IOLDERC20DispatcherTrait}
};

const THOUSAND_TOKENS: u256 = 1000000000000000000000;

fn deploy_erc20() -> IERC20Dispatcher {
    let class_hash = ERC20::TEST_CLASS_HASH.try_into().unwrap();
    let (contract_address, _) = deploy_syscall(class_hash, 0, array![].span(), true).unwrap();
    IERC20Dispatcher { contract_address }
}

fn sender() -> ContractAddress {
    'sender'.try_into().unwrap()
}

fn recipient() -> ContractAddress {
    'recipient'.try_into().unwrap()
}

#[test]
#[available_gas(20000000)]
fn balance_of() {
    let erc20 = deploy_erc20();

    assert(erc20.balance_of(sender()) == THOUSAND_TOKENS, 'Fake balance wrong');
// assert(actual_balance(sender()) == 0, 'Actual balance wrong');
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

    assert(erc20.balance_of(sender()) == THOUSAND_TOKENS, 'Fake before balance 42 wrong');

    // assert(actual_balance(sender()) == 0, 'Actual before balance 42 wrong');
    assert(erc20.balance_of(recipient()) == THOUSAND_TOKENS, 'Fake before balance 21 wrong');
    // assert(actual_balance(recipient()) == 0, 'Actual before balance 21 wrong');

    set_contract_address(sender());
    erc20.transfer(recipient(), 1);

    assert(erc20.balance_of(sender()) == THOUSAND_TOKENS - 1, 'Fake balance 42 wrong');
    // assert(actual_balance(sender()) == THOUSAND_TOKENS, 'Actual balance 42 wrong');
    assert(erc20.balance_of(recipient()) == THOUSAND_TOKENS + 1, 'Fake balance 21 wrong');
// assert(actual_balance(recipient()) == THOUSAND_TOKENS + 2, 'Actual balance 21 wrong');
}

#[test]
#[available_gas(20000000)]
fn test_transfer_retro() {
    let erc20 = deploy_erc20();
    let old_erc20 = IOLDERC20Dispatcher { contract_address: erc20.contract_address };

    assert(old_erc20.balanceOf(sender()) == THOUSAND_TOKENS, 'Fake before balance 42 wrong');
    // assert(actual_balance(sender()) == 0, 'Actual before balance 42 wrong');
    assert(old_erc20.balanceOf(recipient()) == THOUSAND_TOKENS, 'Fake before balance 21 wrong');
    // assert(actual_balance(recipient()) == 0, 'Actual before balance 21 wrong');

    set_contract_address(sender());
    erc20.transfer(recipient(), 1);

    assert(old_erc20.balanceOf(sender()) == THOUSAND_TOKENS - 1, 'Fake balance 42 wrong');
    // assert(actual_balance(sender()) == THOUSAND_TOKENS, 'Actual balance 42 wrong');
    assert(old_erc20.balanceOf(recipient()) == THOUSAND_TOKENS + 1, 'Fake balance 21 wrong');
// assert(actual_balance(recipient()) == THOUSAND_TOKENS + 1 + 1, 'Actual balance 21 wrong');
}

#[test]
#[available_gas(20000000)]
fn test_transfer_100() {
    let erc20 = deploy_erc20();

    assert(erc20.balance_of(sender()) == THOUSAND_TOKENS, 'Fake before balance 42 wrong');
    // assert(actual_balance(sender()) == 0, 'Actual before balance 42 wrong');
    assert(erc20.balance_of(recipient()) == THOUSAND_TOKENS, 'Fake before balance 21 wrong');
    // assert(actual_balance(recipient()) == 0, 'Actual before balance 21 wrong');

    set_contract_address(sender());
    erc20.transfer(recipient(), 100);

    assert(erc20.balance_of(sender()) == THOUSAND_TOKENS - 100, 'Fake balance 42 wrong');
    // assert(actual_balance(sender()) == THOUSAND_TOKENS - 99, 'Actual balance 42 wrong');
    assert(erc20.balance_of(recipient()) == THOUSAND_TOKENS + 100, 'Fake balance 21 wrong');
// assert(actual_balance(recipient()) == THOUSAND_TOKENS + 100 + 1, 'Actual balance 21 wrong');
}

#[test]
#[available_gas(20000000)]
fn test_transfer_all() {
    let erc20 = deploy_erc20();

    set_contract_address(sender());
    erc20.transfer(recipient(), THOUSAND_TOKENS);

    assert(erc20.balance_of(sender()) == 0, 'Fake balance 42 wrong');
// assert(actual_balance(sender()) == 1, 'Actual balance 42 wrong');
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('u256_sub Overflow', 'ENTRYPOINT_FAILED'))]
fn test_transfer_all_and_transfer_again() {
    let erc20 = deploy_erc20();

    set_contract_address(sender());
    erc20.transfer(recipient(), THOUSAND_TOKENS);

    erc20.transfer(recipient(), 1);
}
// TODO transfer and transfer back


