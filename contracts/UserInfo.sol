// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;

import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";

/// @title Contract for storing permissions and information of users
/// @author Robert Cowlishaw @0x365
/// @dev WIP --- Not tested just an example
contract UserInfo {

    using Counters for Counters.Counter;

    Counters.Counter private id_counter;

    // Map user address to id values
    mapping (address => uint) map_id;
    // Map id value to all user data
    mapping (uint => UserData) map_user_data;
    
    struct UserData {
        address user_address;
        string name;
        uint creation_time;
        bool approved_requestor;
        bool approved_provider;
        bool admin;    // For adding new users
        // Can add more stuff
    }
    
    /// @notice Give first deployer admin privilages and id 0
    /// @param _name Name that user would like on profile
    constructor (
        string memory _name
    ) {
        id_counter.increment();
        uint new_id_counter = id_counter.current();
        map_id[msg.sender] = new_id_counter;
        map_user_data[new_id_counter] = UserData({
            user_address: msg.sender,
            name: _name,
            creation_time: block.timestamp,
            approved_requestor: true,
            approved_provider: true,
            admin: true
        });
    }

    /// @notice Add new user
    /// @param _name Name that user would like on profile
    function newUser (
        string memory _name
    )
        public
    {
        // Assert that address doesnt already have an id
        // require(map_id[msg.sender] == 0, "Address already has an ID");
        assert(map_id[msg.sender] == 0);
        // Give address new id
        id_counter.increment();
        uint new_id_counter = id_counter.current();
        map_id[msg.sender] = id_counter;
        // Give id new user data
        map_user_data[new_id_counter] = UserData({
            user_address: msg.sender,
            name: _name,
            creation_time: block.timestamp,
            approved_requestor: false,
            approved_provider: false,
            admin: false
        });
    }

    /// @notice Returns the ID of the caller
    /// @return ID the id of the caller
    function whatIsMyID () public view returns(uint) {
        return map_id[msg.sender];
    }

    /// @notice Returns the ID of the input address
    /// @return ID the id of the input address
    function whatIsID (address find) public view returns(uint) {
        return map_id[find];
    }

    /// @notice Change info that doesnt require admin privaliges
    /// @param _name New name that user would like on profile
    function changeName (
        string memory _name
    )
        public
    {
        map_user_data[map_id[msg.sender]].name = _name;
    }

    /// @notice Change privilages of the target id if caller is admin
    /// @param _target_id Id of the user to change privilages for
    /// @param _requestor_privilages New bool values of requestor privilages
    /// @param _provider_privilages New bool values of provider privilages
    /// @param _admin_privilages New bool values of admin privilages
    function givePrivilages (
        uint _target_id,
        bool _requestor_privilages,
        bool _provider_privilages,
        bool _admin_privilages
    ) 
        public
    {
        // Assert that caller is an admin
        // require(map_user_data[map_id[msg.sender]].admin, "Caller is not an admin");
        assert(map_user_data[map_id[msg.sender]].admin = true);
        // Update privilages of input user to those of the input params
        map_user_data[_target_id].approved_requestor = _requestor_privilages;
        map_user_data[_target_id].approved_provider = _provider_privilages;
        map_user_data[_target_id].admin = _admin_privilages;
    }

    /// @notice Check if address is approved for requestor and provider(
    /// @param _user_address The address to check
    /// @return boolbool Returns requestor true/false, provider true/false)
    function checkAddressApproved (
        address _user_address
    )
        public
        view 
        returns (bool, bool)
    {
        return checkIdApproved(map_id[_user_address]);
    }
    
    /// @notice Check if id is approved for requestor and provider(
    /// @param _id The id to check
    /// @return boolbool Returns requestor true/false, provider true/false)
    function checkIdApproved (
        uint _id
    )
        public
        view
        returns (bool, bool)
    {
        return (map_user_data[_id].approved_requestor, map_user_data[_id].approved_provider);
    }
}
