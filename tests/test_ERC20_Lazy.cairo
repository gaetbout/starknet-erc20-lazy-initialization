%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE

const TEST_ADDRESS_1 = 21
const TEST_ADDRESS_2 = 42
const HUNDRED_TOKENS = 100000000000000000000
const ONE_TOKEN = 1000000000000000000

@contract_interface
namespace StorageContract:
    func balanceOf(account : felt) -> (balance : Uint256):
    end

    func actualBalanceOf(account : felt) -> (balance : Uint256):
    end

    func transfer(recipient : felt, amount : Uint256) -> (success : felt):
    end
end

func get_deployed_contract_address{
    syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*
}() -> (contract_address : felt):
    alloc_locals
    local contract_address : felt
    %{ ids.contract_address = deploy_contract("./contracts/ERC20_Lazy.cairo", []).contract_address %}
    return (contract_address)
end

@external
func test_balanceOf{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    let (contract_address) = get_deployed_contract_address()
    let (balance) = StorageContract.balanceOf(contract_address, TEST_ADDRESS_1)

    assert_balance_is(TEST_ADDRESS_1, HUNDRED_TOKENS, 0)
    assert_actual_balance_is(TEST_ADDRESS_1, 0, 0)
    return ()
end

@external
func test_transfer{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    assert_balance_is(TEST_ADDRESS_1, HUNDRED_TOKENS, 0)
    assert_actual_balance_is(TEST_ADDRESS_1, 0, 0)
    assert_balance_is(TEST_ADDRESS_2, HUNDRED_TOKENS, 0)
    assert_actual_balance_is(TEST_ADDRESS_2, 0, 0)

    let (contract_address) = get_deployed_contract_address()
    %{ stop_prank_callable = start_prank(ids.TEST_ADDRESS_1) %}
    let amountToTransfer = Uint256(ONE_TOKEN, 0)
    let (success) = StorageContract.transfer(contract_address, TEST_ADDRESS_2, amountToTransfer)
    assert success = TRUE
    %{ stop_prank_callable() %}

    assert_balance_is(TEST_ADDRESS_1, (HUNDRED_TOKENS - ONE_TOKEN), 0)
    assert_actual_balance_is(TEST_ADDRESS_1, (HUNDRED_TOKENS - ONE_TOKEN), 0)
    assert_balance_is(TEST_ADDRESS_2, (HUNDRED_TOKENS + ONE_TOKEN), 0)
    assert_actual_balance_is(TEST_ADDRESS_2, (HUNDRED_TOKENS + ONE_TOKEN), 0)
    return ()
end

@external
func test_transfer_100{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    assert_balance_is(TEST_ADDRESS_1, HUNDRED_TOKENS, 0)
    assert_actual_balance_is(TEST_ADDRESS_1, 0, 0)
    assert_balance_is(TEST_ADDRESS_2, HUNDRED_TOKENS, 0)
    assert_actual_balance_is(TEST_ADDRESS_2, 0, 0)

    let (contract_address) = get_deployed_contract_address()
    %{ stop_prank_callable = start_prank(ids.TEST_ADDRESS_1) %}
    let amountToTransfer = Uint256(HUNDRED_TOKENS, 0)
    let (success) = StorageContract.transfer(contract_address, TEST_ADDRESS_2, amountToTransfer)
    assert success = TRUE
    %{ stop_prank_callable() %}

    assert_balance_is(TEST_ADDRESS_1, 0, 0)
    assert_actual_balance_is(TEST_ADDRESS_1, 1, 0)
    assert_balance_is(TEST_ADDRESS_2, HUNDRED_TOKENS * 2, 0)
    assert_actual_balance_is(TEST_ADDRESS_2, (HUNDRED_TOKENS * 2) + 1, 0)
    return ()
end

func assert_balance_is{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    account, low, high
):
    let (contract_address) = get_deployed_contract_address()
    let (balance_1) = StorageContract.balanceOf(contract_address, account)
    assert balance_1.low = low
    assert balance_1.high = high
    return ()
end
func assert_actual_balance_is{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    account, low, high
):
    let (contract_address) = get_deployed_contract_address()
    let (balance_1) = StorageContract.actualBalanceOf(contract_address, account)
    assert balance_1.low = low
    assert balance_1.high = high
    return ()
end
