pragma solidity ^0.4.18;

/// @title AbsKYCCertifier - KYCCertifier abstract contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract AbsKYCCertifier {
    function init(address _token, address[] _voters) public returns (bool);
    function claimCertifier(address _certifier, uint256 _expiredTime, bool _isPrimary) public returns(bool);
    function revokeCertifier() public returns(bool);
    function vote() public returns(bool);
    function isCertifier(address _certifier) public view returns(bool);
    function getCertifiers() public view returns(address[]);
    function getPrimaryCertifier() public view returns (address);
}