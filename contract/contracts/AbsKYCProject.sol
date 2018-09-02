pragma solidity ^0.4.18;

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

/// @title AbsKYCProject - AbsKYCProject abstract contract
/// @author - Yusaku Senga - <senga@dri.network>

contract AbsKYCProject {
    function setProject(bytes32 _project, uint256 _price) public returns (uint256);
    function getFeePrice(bytes32 _project) public view returns (uint256);
}