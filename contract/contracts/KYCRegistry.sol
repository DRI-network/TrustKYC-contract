pragma solidity ^0.4.18;

import { AbsKYCCertifier } from "./AbsKYCCertifier.sol";
import { AbsKYCProject } from "./AbsKYCProject.sol";
import { SafeMath } from "./SafeMath.sol";
import { MultiCertifier } from "./MultiCertifier.sol";
import { Freezable } from "./Freezable.sol";

/// @title KYCRegistry - KYCRegistry contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

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
    function confirmCertificate(address _proposer, address _project, address _claimAddress) public can() onlyPrimaryCertifier() returns(bool) {
        
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