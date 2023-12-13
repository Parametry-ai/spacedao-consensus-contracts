// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.19;

import "hardhat/console.sol";
import {Counters} from "@openzeppelin-v4/contracts/utils/Counters.sol";    // (Openzepplin v3, v4)
import {BitMaps} from "@openzeppelin-v5/contracts/utils/structs/BitMaps.sol";  // (Openzepplin v5)
import {EnumerableSet} from "@openzeppelin-v5/contracts/utils/structs/EnumerableSet.sol";  // (Openzepplin v5 in uitls/structs || v3, v4 in utils)

/// @title Contract for storing permissions and information of users
/// @author Antoine Delamare
/// @dev WIP --- check if rating logic & newUser whitelist creation convenient | add a merkleProof verification for the whitelist logic
contract SpaceDAOID {

    // secure increment counter
    using Counters for Counters.Counter;
    // secure set of addresses initializer
    using EnumerableSet for EnumerableSet.AddressSet; 

    // @notice adminOwner = owner of this smart contract
    address private immutable adminOwner;

    // @notice teamAdmin = array of admins addresses of this smart contract
    address[] private teamAdmin;
    // @notice teamNames = array of admins names of this smart contract
    string[] private teamNames;
    // @notice teamLength = length of admins names (or addresses) of this smart contract
    uint private immutable teamLength;

    // @notice Counter of userIds
    Counters.Counter private _userIds;

    // @notice initialisation of a set of addresses for admin roles (protect duplicate addresses)
    EnumerableSet.AddressSet private _adminAddresses;

    /// Companies whitelist (Gasless optimized +++)
    /// @notice one user initiated as whitelisted throug his _userId (gasless alternative to mapping)
    BitMaps.BitMap private adminIDs_list;
    BitMaps.BitMap private providerIDs_list;
    BitMaps.BitMap private requestorIDs_list;
    // @dev Library for managing uint256 to bool mapping in a compact and efficient way, provided the keys are sequential.
    // Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
    // BitMaps pack 256 booleans across each bit of a single 256-bit slot of uint256 type.
    // Hence booleans corresponding to 256 sequential indices would only consume a single slot,
    // unlike the regular bool which would consume an entire slot for a single value.
    // This results in gas savings in two ways:
    // 1) Setting a zero value to non-zero only once every 256 times
    // 2) Accessing the same warm slot for every 256 sequential indices

    // Struct User
    struct UserData {
        uint256 userId; // id of the user
        address user_address; // address of the user
        string name; // name of the user
        uint creation_time; // timestamp of the creation
        uint256 reliability; // Probabilité continue de fiabilité
        bool active; // check if user active or not
    }

    // Map id value to all user data
    mapping (uint => UserData) public map_user_data;
    // Map user address to id values
    mapping (address => uint) public map_id;
    
    /// @notice Give firsts deployers admin privilages and userId beginning by 1
    /// @param _adminOwner_name Return Name that the deployer user (adminOwner) would have on his profile
    /// @param _admin_names Return array of Names that a pack of users (admins) would have on their profile
    /// @param _admin_addresses Return array of addresses that a pack of users (admins) would use
    constructor (string memory _adminOwner_name,
                 string[] memory _admin_names,
                 address[] memory _admin_addresses)
    {
        console.log("DEBUG");
        require(msg.sender != address(0), "Invalid admin address");
        //require(_admin_addresses.length > 0 && _admin_names.length > 0, "At least one admin address is required");
        //require(_admin_names.length == _admin_addresses.length, "Mismatched array lengths");
        
        adminOwner = msg.sender; // AdminOwner immutable initiated
        teamAdmin = _admin_addresses;
        teamNames = _admin_names;
        teamLength = _admin_addresses.length;

        // Initialize admin_owner
        if (msg.sender == adminOwner) {
            require(_adminAddresses.add(msg.sender), "Duplicate address detected in array set of admin addresses");
            _initAdmin(_adminOwner_name, msg.sender);
        }
        // Initialize admins_list
        for (uint i = 0; i < teamLength; i++) {
            require(_adminAddresses.add(_admin_addresses[i]), "Duplicate address detected in array set of admin addresses");
            _initAdmin(_admin_names[i], _admin_addresses[i]);
        }
        
    }

    /// @notice modifier for adminOwner, owner of this smart contract (Gasless optimized +++)
    modifier onlyAdmin() {
        _checkAdmin();
        _;
    }
    

    /// @notice Add new user (with role Role.None or Role.admin if adminOwner == msg.sender)
    /// @param _name Name that user would like on profile
    /// @dev WIP --- Is the enum logic convenient ?
    function newUser(string memory _name, address _user_address) public returns(uint256) {
        // Assert that address doesnt already have an id
        uint currentUserId = whatIsAddressID(_user_address);
        require(currentUserId <= _userIds.current(), "User already exists");
        require(!getUser(currentUserId).active, "msg.sender can only be created as newUser once");
        // Give address new id
        _userIds.increment();
        uint newUserId = _userIds.current();
        map_id[_user_address] = newUserId;

        // Give id new user data
        map_user_data[newUserId] = UserData({
            userId: newUserId,
            user_address: _user_address,
            name: _name,
            creation_time: block.timestamp,
            reliability: 500, // Set an initial reliability value (adjust as needed)
            active: true
        });
        return newUserId;

    }

    /// @notice Returns the ID of the caller
    /// @return ID the id of the caller
    /// @dev WIP --- is it convenient to keep whatsIsMyId if we can find an user with userId ?
    function whatIsMyID() public view returns(uint) {
        require(msg.sender != address(0), "Invalid admin address");
        return map_id[msg.sender];
    }

    /// @notice Returns the ID of the input address
    /// @return ID the id of the input address
    /// @dev WIP --- is it convenient to keep whatsIsID if we can find an user with userId ?
    function whatIsAddressID(address _user) public view returns(uint) {
        require(_user != address(0), "Invalid admin address");
        return map_id[_user];
    }

    /// @notice Change info that doesnt require admin privilages
    /// @param _name New name that user would like on profile
    /// @dev WIP --- is the require logic of check if an user is Role.None correctly implementated ?
    function changeName (string memory _name) external {
        uint userId = whatIsMyID();
        // require(getUser(userId).role != Role.REQUESTOR, "Not authorized. Only attributed Roles can change their names");
        map_user_data[userId].name = _name;
    }

    /// @notice Change privilages of the target id if caller is admin (Gasless optimized +++)
    /// @param _userId | change Role of a User if User active & add _userId to whitelist if Role is Role.Provider
    /// @dev WIP --- Separate new admin privilage of provider privilage | if validated, need to add a MerkleProof logic to secure the whitelist
    function givePrivilages(uint _userId) external onlyAdmin {
        // Check if userId already created
        require(_userId <= _userIds.current(), "Invalid target user ID");
        // Check if user is activated
        require(getUser(_userId).active, "User does not exist");

        // Add the user to the providers_list
        // Check if user is out of whitelist
        require(!BitMaps.get(providerIDs_list, _userId), "User already designated as a provider");
        // Update 2 : set user as whitelisted with BitMaps logic
        BitMaps.setTo(providerIDs_list, _userId, true);
    }

    /// @notice get an array of all activated users inside UserInfo.sol
    /// @return UserData[] Returns all properties of each UserData struct of this smart contract
    function getAllUsers() public view returns (UserData[] memory) {
      uint256 totalUserCount = _userIds.current();
      uint256 currentIndex = 0;

      UserData[] memory users = new UserData[](totalUserCount);
      for (uint i = 0; i < totalUserCount; i++) {
        uint currentId = map_user_data[i + 1].userId;
        UserData storage currentUser = map_user_data[currentId];
        users[currentIndex] = currentUser;
        currentIndex += 1;
      }
      return users;
    }
    
    /// @notice get an UserData struct by this userID
    /// @param _userId The id to check
    /// @return UserData Returns all properties of the UserData by his userId
    function getUser(uint _userId) public view returns (UserData memory) {
        return map_user_data[_userId];
    }

    /// @notice Get all admin addresses
    /// @return address[] Returns an array of all admin addresses (Openzeppelin's EnumerableSet)
    function getAdminAddresses() public view returns (address[] memory) {
        require(_adminAddresses.length() > 0, "No admin addresses yet initialized");
        return _adminAddresses.values();
    }

    /// @notice private function to initiate admin roles of users
    function _initAdmin(string memory _name, address _user_address) private {
        uint256 currentUserId = newUser(_name, _user_address);
        require(!BitMaps.get(adminIDs_list, currentUserId), "Admin already exists");
        BitMaps.setTo(adminIDs_list, currentUserId, true);
    }

    /// @notice Check if the msg.sender is an approved admin (Gasless optimized +++)
    function _checkAdmin() internal view virtual {
        uint userId = whatIsMyID();
        require(BitMaps.get(adminIDs_list, userId), "Not authorized. Admin only");
    }
    
}
