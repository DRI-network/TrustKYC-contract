pragma solidity ^0.4.18;
import { SafeMath } from "./SafeMath.sol";
import { Freezable } from "./Freezable.sol";

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

/// @title KYCProject - KYCProject contract
/// @author - Yusaku Senga - <senga@dri.network>

contract KYCProject is Freezable {
  
    //using safemath
    using SafeMath for uint256;

    /**
     * Storage
     */

    mapping(bytes32 => uint256) projectFees;

    /** 
     * Event
     */

    event SetProject(bytes32 indexed project, uint256 indexed price);

    /**
     * @notice Constructor method
     * @dev Constructor is called when contract deployed.
     */

    constructor() public {}

    /**
     * functions
     */


    function setProject(bytes32 _project, uint256 _price) public can() onlyOwner() returns (uint256) {
        require(_price >= 0);
        projectFees[_project] = _price;
        emit SetProject(_project, _price);
        return projectFees[_project];
    }

    function getFeePrice(bytes32 _project) public view returns (uint256) {
        return projectFees[_project];
    }
}