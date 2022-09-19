%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE

const TEST_ADDRESS_1 = 21;
const TEST_ADDRESS_2 = 42;
const HUNDRED_TOKENS = 100000000000000000000;
const ONE_TOKEN = 1000000000000000000;

@contract_interface
namespace StorageContract {
    func balanceOf(account: felt) -> (balance: Uint256) {
    }

    func actualBalanceOf(account: felt) -> (balance: Uint256) {
    }

    func transfer(recipient: felt, amount: Uint256) -> () {
    }
}

@external
func __setup__() {
    %{ context.contract_a_address = deploy_contract("./contracts/ERC20_Lazy.cairo").contract_address %}
    return ();
}

func get_deployed_contract_address{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}(
    ) -> (contract_address: felt) {
    tempvar contract_address;
    %{ ids.contract_address = context.contract_a_address %}
    return (contract_address,);
}

@external
func test_balanceOf{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    let (contract_address) = get_deployed_contract_address();
    let (balance) = StorageContract.balanceOf(contract_address, TEST_ADDRESS_1);

    assert_balance_is(TEST_ADDRESS_1, HUNDRED_TOKENS, 0);
    assert_actual_balance_is(TEST_ADDRESS_1, 0, 0);
    return ();
}

@external
func test_transfer{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    assert_balance_is(TEST_ADDRESS_1, HUNDRED_TOKENS, 0);
    assert_actual_balance_is(TEST_ADDRESS_1, 0, 0);
    assert_balance_is(TEST_ADDRESS_2, HUNDRED_TOKENS, 0);
    assert_actual_balance_is(TEST_ADDRESS_2, 0, 0);

    let (contract_address) = get_deployed_contract_address();
    %{ stop_prank_callable = start_prank(ids.TEST_ADDRESS_1, target_contract_address=ids.contract_address) %}
    let amountToTransfer: Uint256 = Uint256(ONE_TOKEN, 0);
    StorageContract.transfer(contract_address, TEST_ADDRESS_2, amountToTransfer);
    %{ stop_prank_callable() %}

    assert_balance_is(TEST_ADDRESS_1, (HUNDRED_TOKENS - ONE_TOKEN), 0);
    assert_actual_balance_is(TEST_ADDRESS_1, (HUNDRED_TOKENS - ONE_TOKEN + 1), 0);
    assert_balance_is(TEST_ADDRESS_2, (HUNDRED_TOKENS + ONE_TOKEN), 0);
    assert_actual_balance_is(TEST_ADDRESS_2, (HUNDRED_TOKENS + ONE_TOKEN + 1), 0);
    return ();
}

@external
func test_transfer_100{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    assert_balance_is(TEST_ADDRESS_1, HUNDRED_TOKENS, 0);
    assert_actual_balance_is(TEST_ADDRESS_1, 0, 0);
    assert_balance_is(TEST_ADDRESS_2, HUNDRED_TOKENS, 0);
    assert_actual_balance_is(TEST_ADDRESS_2, 0, 0);

    let (contract_address) = get_deployed_contract_address();
    %{ stop_prank_callable = start_prank(21, target_contract_address=ids.contract_address) %}
    let amountToTransfer = Uint256(HUNDRED_TOKENS, 0);
    StorageContract.transfer(contract_address, TEST_ADDRESS_2, amountToTransfer);
    %{ stop_prank_callable() %}

    assert_balance_is(TEST_ADDRESS_1, 0, 0);
    assert_actual_balance_is(TEST_ADDRESS_1, 1, 0);
    assert_balance_is(TEST_ADDRESS_2, HUNDRED_TOKENS * 2, 0);
    assert_actual_balance_is(TEST_ADDRESS_2, (HUNDRED_TOKENS * 2) + 1, 0);
    return ();
}

@external
func test_transfer_100_and_transferAgain{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    alloc_locals;
    let (contract_address) = get_deployed_contract_address();
    %{ stop_prank_callable = start_prank(21, target_contract_address=ids.contract_address) %}
    let amountToTransfer = Uint256(HUNDRED_TOKENS, 0);
    StorageContract.transfer(contract_address, TEST_ADDRESS_2, amountToTransfer);

    let oneAsUint = Uint256(1, 0);
    %{ expect_revert(error_message="ERC20: transfer amount exceeds balance") %}
    StorageContract.transfer(contract_address, TEST_ADDRESS_2, oneAsUint);
    %{ stop_prank_callable() %}

    return ();
}

func assert_balance_is{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}(
    account, low, high
) {
    let (contract_address) = get_deployed_contract_address();
    let (balance) = StorageContract.balanceOf(contract_address, account);
    assert balance.low = low;
    assert balance.high = high;
    return ();
}

func assert_actual_balance_is{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}(
    account, low, high
) {
    let (contract_address) = get_deployed_contract_address();
    let (balance) = StorageContract.actualBalanceOf(contract_address, account);
    assert balance.low = low;
    assert balance.high = high;
    return ();
}
