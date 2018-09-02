pragma solidity ^0.4.18;

/// @title AbsKYCProject - AbsKYCProject abstract contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract AbsKYCProject {
    function setProject(address _project, uint256 _price) public returns (uint256);
    function getFeePrice(address _project) public view returns (uint256);
}