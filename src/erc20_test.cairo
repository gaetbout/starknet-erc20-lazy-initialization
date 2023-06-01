use starknet::contract_address_const;
use starknet::testing::set_block_timestamp;
use starknet::testing::set_caller_address;
use core::traits::Into;

use lazy::ERC20;

const TEST_ADDRESS_1: felt252 = 21;
const TEST_ADDRESS_2: felt252 = 42;
const HUNDRED_TOKENS: felt252 = 100000000000000000000;
const ONE_TOKEN: felt252 = 1000000000000000000;

// set_caller_address(contract_address_const::<42>());

// #[test]
// #[available_gas(2000000)]
// fn balance_of() {
//     let fake_balance = ERC20::balance_of(contract_address_const::<42>());
//     assert(fake_balance == 100000000000000000000.into(), 'Fake balance wrong');
//     let actual_balance = ERC20::balances::read(contract_address_const::<42>());
//     assert(actual_balance == 0.into(), 'Actual balance wrong');
// }

// #[test]
// fn test_transfer() {
//     assert_balance_is(TEST_ADDRESS_1, HUNDRED_TOKENS, 0);
//     assert_actual_balance_is(TEST_ADDRESS_1, 0, 0);
//     assert_balance_is(TEST_ADDRESS_2, HUNDRED_TOKENS, 0);
//     assert_actual_balance_is(TEST_ADDRESS_2, 0, 0);

//     let (contract_address) = get_deployed_contract_address();
//     %{ stop_prank_callable = start_prank(ids.TEST_ADDRESS_1, target_contract_address=ids.contract_address) %}
//     let amountToTransfer: Uint256 = Uint256(ONE_TOKEN, 0);
//     StorageContract.transfer(contract_address, TEST_ADDRESS_2, amountToTransfer);
//     %{ stop_prank_callable() %}

//     assert_balance_is(TEST_ADDRESS_1, (HUNDRED_TOKENS - ONE_TOKEN), 0);
//     assert_actual_balance_is(TEST_ADDRESS_1, (HUNDRED_TOKENS - ONE_TOKEN + 1), 0);
//     assert_balance_is(TEST_ADDRESS_2, (HUNDRED_TOKENS + ONE_TOKEN), 0);
//     assert_actual_balance_is(TEST_ADDRESS_2, (HUNDRED_TOKENS + ONE_TOKEN + 1), 0);
    
// }

// #[test]
// fn test_transfer_100() {
//     assert_balance_is(TEST_ADDRESS_1, HUNDRED_TOKENS, 0);
//     assert_actual_balance_is(TEST_ADDRESS_1, 0, 0);
//     assert_balance_is(TEST_ADDRESS_2, HUNDRED_TOKENS, 0);
//     assert_actual_balance_is(TEST_ADDRESS_2, 0, 0);

//     let (contract_address) = get_deployed_contract_address();
//     %{ stop_prank_callable = start_prank(21, target_contract_address=ids.contract_address) %}
//     let amountToTransfer = Uint256(HUNDRED_TOKENS, 0);
//     StorageContract.transfer(contract_address, TEST_ADDRESS_2, amountToTransfer);
//     %{ stop_prank_callable() %}

//     assert_balance_is(TEST_ADDRESS_1, 0, 0);
//     assert_actual_balance_is(TEST_ADDRESS_1, 1, 0);
//     assert_balance_is(TEST_ADDRESS_2, HUNDRED_TOKENS * 2, 0);
//     assert_actual_balance_is(TEST_ADDRESS_2, (HUNDRED_TOKENS * 2) + 1, 0);
    
// }

// #[test]
// fn test_transfer_100_and_transferAgain{
//     syscall_ptr: felt252*, range_check_ptr, pedersen_ptr: HashBuiltin*
// }() {
//     alloc_locals;
//     let (contract_address) = get_deployed_contract_address();
//     %{ stop_prank_callable = start_prank(21, target_contract_address=ids.contract_address) %}
//     let amountToTransfer = Uint256(HUNDRED_TOKENS, 0);
//     StorageContract.transfer(contract_address, TEST_ADDRESS_2, amountToTransfer);

//     let oneAsUint = Uint256(1, 0);
//     %{ expect_revert(error_message="ERC20: transfer amount exceeds balance") %}
//     StorageContract.transfer(contract_address, TEST_ADDRESS_2, oneAsUint);
//     %{ stop_prank_callable() %}

    
// }


// fn assert_balance_is(
//     account, low, high
// ) {
//     let (contract_address) = get_deployed_contract_address();
//     let (balance) = StorageContract.balanceOf(contract_address, account);
//     assert balance.low = low;
//     assert balance.high = high;
    
// }

// fn assert_actual_balance_is(account, low, high) {
//     let (contract_address) = get_deployed_contract_address();
//     let (balance) = StorageContract.actualBalanceOf(contract_address, account);
//     assert balance.low = low;
//     assert balance.high = high;
// }
