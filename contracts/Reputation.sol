// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;

import {SafeMath} from "@openzeppelin-v4/contracts/utils/math/SafeMath.sol";

/// @title Contract for storing reputation of users based on address
/// @author Robert Cowlishaw @0x365
/// @dev WIP --- Not tested just an example
contract Reputation {

    using SafeMath for uint256;

    // Map user address to reputation values
    mapping (address => uint) rep;

    /// @notice Gives reputation of input user
    /// @param _target_address is user address to get reputation of
    /// @return uint is reputation of user
    function getReputation (
        address _target_address
    ) 
        public
        view
        returns (uint)
    {
        return rep[_target_address];
    }

    /// @notice Change reputation
    function changeReputation (
        address _target_address
    )
        public
    {
        // How do we make it call each other as cant deploy at same time
    }

}
