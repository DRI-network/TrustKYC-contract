pragma solidity ^0.4.18;

import { AbsKYCCertifier } from "./AbsKYCCertifier.sol";
import { AbsKYCProject } from "./AbsKYCProject.sol";
import { SafeMath } from "./SafeMath.sol";
import { MultiCertifier } from "./MultiCertifier.sol";
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

/// @title KYCRegistry - KYCRegistry contract
/// @author - Yusaku Senga - <senga@dri.network>


contract KYCRegistry is MultiCertifier,Freezable {
    //using safemath
    using SafeMath for uint256;

    /**
        * Storage
        */

    mapping(address => mapping(address => uint)) balanceWei;
    mapping(address => mapping(address => bool)) whitelists;
    AbsKYCCertifier certifier;
    AbsKYCProject project;
    address public primaryCertifier;

    enum Status {
        Deployed,
        Initialized
    }
    Status status;

    /**
        * Modifier
        */

    modifier onlyPrimaryCertifier() {
        require(primaryCertifier == msg.sender);
        _;
    }

    /** 
        * Event
        */

    event WhiteListed(address indexed proposer, address indexed claimAddress, address indexed certifier);

    /**
        * @notice Constructor method
        * @dev Constructor is called when contract deployed.
        */

    constructor() public {
        status = Status.Deployed;
    }

    /**
        * functions
        */


    /// @notice setConfig execute to initializing registry.
    /// @dev setConfig is called by Owner.
    /// @param  _cert    to set up AbsKYCCertifier contract.
    function init(address _cert, address _proj) public can() onlyOwner()  returns (bool) {

        require(status == Status.Deployed);

        certifier = AbsKYCCertifier(_cert);

        project = AbsKYCProject(_proj);

        primaryCertifier = certifier.getPrimaryCertifier();

        status = Status.Initialized;

        return true;
    }

    /// @notice submitCertificate puts a new application.
    /// @dev submitCertificate is called by proposer.
    function submitCertificate() public payable can() returns(bool) {

        balanceWei[primaryCertifier][msg.sender] = balanceWei[primaryCertifier][msg.sender].add(msg.value);

        return true;
    }

    /// @notice confirmCertificate executes a settlement to puts application.
    /// @dev setConfig is called by PrimaryCertifier.
    /// @param  _proposer    This applications proposer.
    /// @param  _project      This applications project.
    /// @param  _claimAddress  This applications claim Ethereum address.
    function confirmCertificate(address _proposer, bytes32 _project, address _claimAddress) public can() onlyPrimaryCertifier() returns(bool) {
        
        uint256 fee = project.getFeePrice(_project);
        
        require(balanceWei[primaryCertifier][_proposer] >= fee);

        require(primaryCertifier.send(fee));

        uint256 refund = balanceWei[primaryCertifier][_proposer] - fee;

        require(_proposer.send(refund));

        whitelists[primaryCertifier][_claimAddress] = true;

        balanceWei[primaryCertifier][_proposer] = 0;

        emit WhiteListed(_proposer, _claimAddress, primaryCertifier);
        return true;
    }

    function withdraw(address _certifier, address _proposer) public can() onlyOwner() returns (bool) {

        require(balanceWei[_certifier][_proposer] >= 0);

        require(_proposer.send(balanceWei[_certifier][_proposer]));

        balanceWei[_certifier][_proposer] = 0;

        return true;
    }

    /// @notice getBalanceOfWei get deposited ether balance of _proposer.
    /// @dev getBalanceOfWei is called by anyone.
    function getBalanceOfWei(address _proposer) public view returns(uint256) {
        return balanceWei[primaryCertifier][_proposer];
    }

    /**
        * allow multiple party integration functions
        */

    /// @notice certified return bool whether who is certified.
    /// @dev certified is called by anyone.
    function certified(address _who) public view returns (bool) {
        return whitelists[primaryCertifier][_who];
    }

    /// @notice getCertifier return primary certifier if who has been certified.
    /// @dev getCertifier is called by anyone.
    function getCertifier(address _who) public view returns (address) {
        if (whitelists[primaryCertifier][_who]) {
            return primaryCertifier;
        }
        return 0x0;
    }

    /// @notice certifiedFrom return bool whether who is certiied with certifier.
    /// @dev certifiedFrom is called by anyone.
    function certifiedFrom(address _certifier, address _who) public view returns (bool) {
        if (whitelists[_certifier][_who]) {
            return true;
        }
        return false;
    } 

    /**
     * Fallback function. Should be bypass to submitCertificate function.
     */

    function () public payable {
        submitCertificate();
    }
}