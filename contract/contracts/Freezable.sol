pragma solidity ^0.4.18;

/*
 * Copyright (C) 2017 DRI
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

/// @title Freezable - Freezable contract
/// @author - Yusaku Senga - <senga@dri.network>

contract Freezable {

    /**
    * Storage
    */

    address owner;
    bool executable;

    /**
    * Modifier
    */

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier can() {
        require(executable);
        _;
    }

    /**
    * @notice Constructor method
    * @dev Constructor is called when contract deployed.
    */

    constructor() public {
        owner = msg.sender;
        executable = true;
    }

    /**
    * functions
    */

    /// @notice freeza execute to initializing registry.
    /// @dev freeza is called by Owner.
    /// @param  _flag    to be stop all executable function when occurring emergency.
    function freeza(bool _flag) public onlyOwner() returns (bool) {
        executable = _flag;
        return executable;
    }
}

