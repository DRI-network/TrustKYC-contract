pragma solidity ^0.4.18;
import { EIP20TokenStandard } from "./EIP20TokenStandard.sol";

/*
 * Copyright (C) 2017-2018 DRI
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/// @title KYCToken - KYCToken contract
/// @author - Yusaku Senga - <senga@dri.network>

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