pragma solidity ^0.4.18;

/// @title AbsKYCProject - AbsKYCProject abstract contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract AbsKYCProject {
    function setProject(bytes32 _project, uint256 _price) public returns (uint256);
    function getFeePrice(bytes32 _project) public view returns (uint256);
}