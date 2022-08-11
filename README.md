![Tests](https://github.com/gaetbout/starknet-erc20-lazy-initialization/actions/workflows/protostar.yml/badge.svg)  [![Twitter URL](https://img.shields.io/twitter/url.svg?label=Follow%20%40gaetbout&style=social&url=https%3A%2F%2Ftwitter.com%2Fgaetbout)](https://twitter.com/gaetbout)

# starknet-erc20-lazy-initialization
## 🪂 Description
This is the biggest airdrop ever. Every address existing or that will exist will have 100 tokens of this token.  
I didn't run a computer to send this token to every possible address I just modify the default implementation of an ERC20 contract to make it lazy initialized.  
Note that it could also be used as a testnet token to avoid user to have to mint the tokens.

## 🤔 But how?
First I started by copying [the default ERC20 of OpenZeppelin (at this date)](hhttps://github.com/OpenZeppelin/cairo-contracts/blob/main/src/openzeppelin/token/erc20/library.cairo). Then I just had to adapt two methods.  
In this case, we want to give each user 100 tokens, and there are 18 decimals to our token.  
If I speak about a unit of token refer to 10<sup>-18</sup> (for Ethereum is is Wei)

### ⚖️ balanceOf
Because this is the entry point of an ERC20 to read the balance of a user (how unexpected, right?) it is where we have to make our first little modification.  
It is as simple as reading the actual balance of the user: 
 - if it is 0 we return a "fake" value with the initial tokens we want to grant each user (100 tokens in this case).
 - if it is not zero, we just return the balance minus 1 (this will be explained in the next section (hint: 1 is the new zero)).
There is also a method actualBalanceOf which will return the real value of the user's storage variable.

### 📤 _transfer
This is were the magic happens (understand: lazy initialization).  
This is the same as written by OpenZeppelin with some adjustemnts:  
 1. Checking that the UINT256 is valid 
 2. Checking that the sender is valid
 3. Checking that the receiver is valid
 4. Checking that the sender and the receiver have funds, if not we mint 100 tokens + 1 unit of token them for each addresses of the transfer.  
 Why initialize both addresses?  
 This is to avoid people sending 1 unit of the token to someone and make their initial balance to zero.  
 Why adding 1 unit of token to the balance?
 This acts as the new zero, since balanceOf is going the return either 100 or the actual balance value minus 1.
 So if the user has 1 unit of token the balance won't go in the zero condition and return balance minus one ( 1 - 1 = 0 ) therefore zero. 
 5. Checking that there is enough funds to make the transfer.  
 This part had to be updated to make use of balanceOf instead of reading directly from the storage var.
 6. Updating the sender's balance.  
 This is also modified because we have to take care to add back 1 to make the balance working correctly.
 7. The rest is unchanged 
 

## 🌡️ Tests

*Prerequisite - Have a working cairo environment and [protostar installed](https://docs.swmansion.com/protostar/docs/tutorials/installation).*  
To run the test suite, clone this repository using the **--recurse-submodules** option and put yourself at the root of it. 
If you forgot to use that flag, you can check [this page](https://docs.swmansion.com/protostar/docs/tutorials/dependencies-management).  
Compile the contracts using `protostar build` or run the tests using `protostar test`.   
For more  details check the Actions tab of this GitHub repository. 

## 📖 Ressources
 - [The original article](https://kf106.medium.com/how-i-created-the-worlds-largest-airdrop-of-all-time-b33b153857c4)
 - [The deployed contract on Etherum](https://etherscan.io/address/0xe7c4F86Ab703343b055433ceE05252158cbb305B#code)
 - [Lazy initialization](https://en.wikipedia.org/wiki/Lazy_initialization)
 - [Some (very) helpful video](https://youtu.be/CcVf_e2DIQU)

## 📄 License

**starknet-erc20-lazy-initialization** is released under the [MIT](https://en.wikipedia.org/wiki/MIT_License).




