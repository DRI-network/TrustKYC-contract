pragma solidity ^0.4.18;
import { EIP20TokenStandard } from "./EIP20TokenStandard.sol";

/// @title KYCToken - KYCToken contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract KYCToken is EIP20TokenStandard {
    /// using safemath
    /// declaration token name
    string public name = "KYCToken";
    /// declaration token symbol
    string public symbol = "KYC";
    /// declaration token decimals
    uint8 public decimals = 18;
    
    /**
     * @notice Constructor method
     * @dev Constructor is called when contract deployed.
     */

    constructor() public {
        balances[msg.sender] = 100000000 * (10 ** uint(decimals));
        totalSupply = balances[msg.sender];
    }
}