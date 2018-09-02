pragma solidity ^0.4.18;
import { KYCToken } from "./KYCToken.sol";
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

/// @title KYCCertifier - KYCCertifier contract
/// @author - Yusaku Senga - <senga@dri.network>

contract KYCCertifier is Freezable {
    ///using safemath
    using SafeMath for uint256;
  
    /**
     * Storage
     */

    KYCToken public token;
    bool public isVoteRound;
    uint256 public expireTime;
    uint256 public tokenDecimals;
    address public pendingCertifier;
    uint256 public totalVoted;
    bool public isPrimary;
    uint256 public totalVotablePowers;
    address[] certifierLists;
    address primaryCertifier;
    mapping(address => bool) certifiers;

    enum Status {
      Deployed,
      Initialized
    }
    Status status;
  
    /**
     * Event
     */

    event AddKYCCertifier(address _certifier);
    event SetPrimaryCertifier(address _primaryCertifier);

    /**
     * Modifier
     */

    modifier onlyCertifier() {
        require(isCertifier(msg.sender));
        _;
    }

    /**
     * @notice Constructor method
     * @dev Constructor is called when contract deployed.
     */

    constructor() public {
        status = Status.Deployed;
    }

    /**
     * Functions
     */

    /// @notice init executes initializing.
    /// @dev init is called only Owner.
    /// @param  _token    to set tokenAddress for KYC token.
    /// @param  _voters   The address to be voter for this certifier contract.
    function init(address _token, address[] _voters) public can() onlyOwner() returns (bool) {
        require(status == Status.Deployed);
        token = KYCToken(_token);
        totalVoted = 0;
        isVoteRound = false;
        totalVotablePowers = 0;
        tokenDecimals = token.decimals();

        require(_voters.length >= 3);

        for (uint i = 0; i < _voters.length; i++) {
            require(!isContract(_voters[i]));
            require(token.balanceOf(_voters[i]) >= 50000 * 10 ** tokenDecimals);
            certifiers[_voters[i]] = true;
            certifierLists.push(_voters[i]);
            totalVotablePowers = totalVotablePowers.add(100);
        }
        primaryCertifier = _voters[0];
        status = Status.Initialized;
        return true;
    }

    /// @notice claimCertifier is called by other certifiers to claim a certification round.
    /// @dev claimCertifier is called only set isVoteRound is false.
    /// @param  _certifier    To add new certifier or to set primaryCertifier.
    /// @param  _time         The time to be executable when time is elapsed.
    /// @param  _isPrimary    The flag of primaryCertifier contract.
    function claimCertifier(address _certifier, uint256 _time, bool _isPrimary) public can() onlyCertifier() returns(bool) {
        require(!isContract(_certifier));

        require(!isVoteRound && totalVoted == 0);

        if (_isPrimary)
            require(isCertifier(_certifier));
        else
            require(!isCertifier(_certifier));

        require(_time >= block.timestamp);

        pendingCertifier = _certifier;

        isPrimary = _isPrimary;

        expireTime = _time;

        isVoteRound = true;

        return true;
    }

    /// @notice revokeCertifier executes revoke a certification round.
    /// @dev revokeCertifier is called by certifier.
    function revokeCertifier() public can() onlyCertifier() returns(bool) {
        require(block.timestamp >= expireTime);
        totalVoted = 0;
        isVoteRound = false;
        return true;
    }

    /// @notice vote executes voting to round.
    /// @dev vote is called by certifier.
    function vote() public can() onlyCertifier() returns(bool) {
        require(isVoteRound);

        uint256 votePower = 50000 * 10 ** tokenDecimals;
    
        require(token.transferFrom(msg.sender, this, votePower));
      
        totalVoted = totalVoted.add(100);
  
        bool result;
        if (isPrimary) {
            result = setPrimaryCertifier();
        } else {
            result = confirmCertifier();
        }
        return result;
    }

    /// @notice confirmCertifier put a new certifier.
    /// @dev confirmCertifier is internal call.
    function confirmCertifier() internal returns(bool) {

        if (totalVoted >= totalVotablePowers * 2 / 3) {
            certifiers[pendingCertifier] = true;
            certifierLists.push(pendingCertifier);
            totalVotablePowers = totalVotablePowers.add(100);
            isVoteRound = false;
            totalVoted = 0;

            emit AddKYCCertifier(pendingCertifier);
            return true;
        }
        return false;
    }


    /// @notice setPrimaryCertifier set to primaryCertifierto.
    /// @dev setPrimaryCertifier is internal call.
    function setPrimaryCertifier() internal returns (bool) {

        if (totalVoted >= (totalVotablePowers * 2 / 3)) {

            primaryCertifier = pendingCertifier;
      
            isVoteRound = false;
            totalVoted = 0;

            SetPrimaryCertifier(primaryCertifier);

            return true;
        }    
        return false;
    }


    /// @notice isContract function to determine if an address is a contract
    /// @param _addr The address being queried
    function isContract(address _addr) view internal returns (bool) {
        if (_addr == 0) 
            return false;
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    /// @notice getPrimaryCertifier returns param primaryCertifier.
    /// @dev getPrimaryCertifier is public call and immutable.
    function getPrimaryCertifier() public view returns (address) {
        return primaryCertifier;
    }

    /// @notice isCertifier returns that whether the certifier or not.
    /// @dev isCertifier is public call and immutable.
    function isCertifier(address _certifier) public view returns(bool) {
        return certifiers[_certifier];
    }

    /// @notice getCertifiers returns all certifiers.
    /// @dev getCertifiers is public call and immutable.
    function getCertifiers() public view returns(address[]) {
        return certifierLists;
    }
}