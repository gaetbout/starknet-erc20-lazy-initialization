# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.3.0 (token/erc20/presets/ERC20.cairo)

%lang starknet

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256, uint256_sub

from openzeppelin.token.erc20.library import ERC20

const NAME = 'The lazy coin'
const SYMBOL = 'LAZY'
const DECIMALS = 18
const INITIAL_TOKEN_AMOUNT = 100000000000000000000  # 100 * 10^18

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    ERC20.initializer(NAME, SYMBOL, DECIMALS)
    return ()
end

#
# Getters
#

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = ERC20.name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = ERC20.symbol()
    return (symbol)
end

@view
func totalSupply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    totalSupply : Uint256
):
    let (totalSupply : Uint256) = ERC20.total_supply()
    return (totalSupply)
end

@view
func decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    decimals : felt
):
    let (decimals) = ERC20.decimals()
    return (decimals)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (balance : Uint256):
    alloc_locals
    let (balance : Uint256) = ERC20.balance_of(account)
    let (isZero) = isEqualZero(balance)
    if isZero == TRUE:
        return (Uint256(INITIAL_TOKEN_AMOUNT, 0))
    end
    let (balanceMinusOne) = uint256_sub(balance, Uint256(1, 0))
    return (balanceMinusOne)
end

@view
func actualBalanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (balance : Uint256):
    let (balance : Uint256) = ERC20.balance_of(account)
    return (balance)
end

func isEqualZero{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    number : Uint256
) -> (isEqualZero : felt):
    if number.low != 0:
        return (FALSE)
    end
    if number.high != 0:
        return (FALSE)
    end
    return (TRUE)
end

@view
func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, spender : felt
) -> (remaining : Uint256):
    let (remaining : Uint256) = ERC20.allowance(owner, spender)
    return (remaining)
end

#
# Externals
#

@external
func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    recipient : felt, amount : Uint256
) -> (success : felt):
    let (sender) = get_caller_address()
    checkAndSetBalanceFor(sender)
    checkAndSetBalanceFor(recipient)
    ERC20.transfer(recipient, amount)
    return (TRUE)
end

func checkAndSetBalanceFor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
):
    let (addressBalance : Uint256) = ERC20.balance_of(address)
    let (isZero) = isEqualZero(addressBalance)
    if (isZero) == TRUE:
        let amountToTransfer = Uint256(INITIAL_TOKEN_AMOUNT + 1, 0)
        ERC20._mint(address, amountToTransfer)
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end
    return ()
end

@external
func transferFrom{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : Uint256
) -> (success : felt):
    ERC20.transfer_from(sender, recipient, amount)
    return (TRUE)
end

@external
func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, amount : Uint256
) -> (success : felt):
    ERC20.approve(spender, amount)
    return (TRUE)
end

@external
func increaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, added_value : Uint256
) -> (success : felt):
    ERC20.increase_allowance(spender, added_value)
    return (TRUE)
end

@external
func decreaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    spender : felt, subtracted_value : Uint256
) -> (success : felt):
    ERC20.decrease_allowance(spender, subtracted_value)
    return (TRUE)
end
