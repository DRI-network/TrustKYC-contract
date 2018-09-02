pragma solidity ^0.4.18;
import { SafeMath } from "./SafeMath.sol";
import { Freezable } from "./Freezable.sol";

/// @title KYCProject - KYCProject contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

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