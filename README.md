# ReentracyGuard_Solidity

## What is the Reengtracny attack?

A reentrancy attack occurs when a malicious function invoke an external function in another vulnerable contract.
Then the untrusted contract make a recursive call back to the original function in an attempt to drain funds.


## mutex solition?

    bool internal mutex; // we need it for our reentrancy protection
    modifier reentrancyguard(){

      require(!mutex, "Do not even thing about it :-)");
      mutex = true;
      ;
      mutex= false;
    }
