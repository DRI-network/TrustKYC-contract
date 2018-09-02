pragma solidity ^0.4.18;

/**
 * @title Multi Certifier from @Parity Technologies
 * license Released under the Apache Licence 2. By Parity Technologies, 2017.
 * https://github.com/paritytech/certifier-website/blob/master/CertifierHandler.sol
 * Contract to allow multiple parties to collaborate over a certification contract.
 * Each certified account is associated with the delegate who certified it.
 * Delegates can be added and removed only by the contract owner.
 */

contract MultiCertifier {
    function certified(address _who) public view returns (bool);
    function getCertifier(address _who) public view returns (address);
    // to certified multiple certifiers.
    function certifiedFrom(address _certifier, address _who) public view returns (bool);
}