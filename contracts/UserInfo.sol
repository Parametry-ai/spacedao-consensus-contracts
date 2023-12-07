// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;

import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
// import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol"; (Openzeppelin VERSION 4)

/// @title Contract for storing permissions and information of users
/// @author Antoine Delamare
/// @dev WIP --- check if rating logic & newUser whitelist creation convenient | add a merkleProof verification for the whitelist logic
contract UserInfo {

    using Counters for Counters.Counter; // openzeppelin's secure increment smart contract
    // using SafeMath for uint256; // openzeppelin's secure arithmetic operations smart contract (VERSION 4)

    // @notice adminOwner = owner of this smart contract
    address private immutable adminOwner;

    // @notice Counter of userIds
    Counters.Counter private _userIds;


    /// Companies whitelist (Gasless optimized +++)
    /// @notice one user initiated as whitelisted with his _userId (gasless alternative to mapping)
    BitMaps.BitMap private providers_whiteList;
    // @dev Library for managing uint256 to bool mapping in a compact and efficient way, provided the keys are sequential.
    // Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
    // BitMaps pack 256 booleans across each bit of a single 256-bit slot of uint256 type.
    // Hence booleans corresponding to 256 sequential indices would only consume a single slot,
    // unlike the regular bool which would consume an entire slot for a single value.
    // This results in gas savings in two ways:
    // 1) Setting a zero value to non-zero only once every 256 times
    // 2) Accessing the same warm slot for every 256 sequential indices


    // ROLES OF USER
    // @notice Role.None : naive (unspecified) user
    // @notice Role.Requestor : Requestor is the spacecraft operator or an automated schedule (from the space operator)
    // @notice Role.Provider : Provider is the company monitoring space sending data to the consensus contract to respond to the request.
    // @notice Role.Admin : owner of this smart contract (give privilages)
    enum Role {Requestor, Provider, Admin}

     // Struct User
    struct UserData {
        uint256 userId; // id of the user
        address user_address; // address of the user
        string name; // name of the user
        uint creation_time; // timestamp of the creation
        uint256 reliability; // Probabilité continue de fiabilité
        Role role; // Role of the user (initiated at None for all users, excepting adminOwner)
        bool active; // check if user active or not
    }

    // Map id value to all user data
    mapping (uint => UserData) internal map_user_data;
    // Map user address to id values
    mapping (address => uint) internal map_id;
    

    /// @notice Give first deployer admin privilages and userId 1
    /// @param _name Name that user would like on profile
    constructor (
        string memory _name
    ) {
        adminOwner = msg.sender; // AdminOwner immutable initiated
        newUser(_name); // First user adminOwner (Role.Admin) initiated
    }

    /// @notice modifier for adminOwner, owner of this smart contract (Gasless optimized +++)
    modifier onlyAdmin() {
        _checkAdmin();
        _;
    }

    /// @notice Add new user (with role Role.None or Role.admin if adminOwner == msg.sender)
    /// @param _name Name that user would like on profile
    /// @dev WIP --- Is the enum logic convenient ?
    function newUser(
        string memory _name
    )
        public
    {
        // Assert that address doesnt already have an id
        require(map_id[msg.sender] <= _userIds.current(), "User already exists");
        require(!map_user_data[map_id[msg.sender]].active, "msg.sender can only be created as newUser once");
        // Give address new id
        _userIds.increment();
        uint newUserId = _userIds.current();
        map_id[msg.sender] = newUserId;

        // Give id new user data
        Role initialRole = (msg.sender == adminOwner) ? Role.Admin : Role.Requestor;

        // Give id new user data
        map_user_data[newUserId] = UserData({
            userId: newUserId,
            user_address: msg.sender,
            name: _name,
            creation_time: block.timestamp,
            role: initialRole,
            reliability: 500, // Set an initial reliability value (adjust as needed)
            active: true
        });
    }

    /// @notice Returns the ID of the caller
    /// @return ID the id of the caller
    /// @dev WIP --- is it convenient to keep whatsIsMyId if we can find an user with userId ?
    function whatIsMyID() public view returns(uint) {
        return map_id[msg.sender];
    }

    /// @notice Returns the ID of the input address
    /// @return ID the id of the input address
    /// @dev WIP --- is it convenient to keep whatsIsID if we can find an user with userId ?
    function whatIsID(address find) public view returns(uint) {
        return map_id[find];
    }

    /// @notice Change info that doesnt require admin privilages
    /// @param _name New name that user would like on profile
    /// @dev WIP --- is the require logic of check if an user is Role.None correctly implementated ?
    function changeName (
        string memory _name
    )
        external
    {
        require(map_user_data[map_id[msg.sender]].role != Role.Requestor, "Not authorized. Only attributed Roles can change their names");
        map_user_data[map_id[msg.sender]].name = _name;
    }

    /// @notice Change privilages of the target id if caller is admin (Gasless optimized +++)
    /// @param _userId | change Role of a User if User active & add _userId to whitelist if Role is Role.Provider
    /// @dev WIP --- if validated, need to add a MerkleProof logic to secure the whitelist
    function givePrivilages (
        uint _userId,
        Role _role
    ) 
        external onlyAdmin
    {
        // Check if userId already created
        require(_userId <= _userIds.current(), "Invalid target user ID");
        // Check if user is activated
        require(!map_user_data[_userId].active, "User does not exist");
        // Check if role of userId is Requestor
        require(map_user_data[_userId].role == Role.Requestor, "New role must be at least Requestor to be changed");

        // UPDATES
        // Update 1 : privilages of input user changed to requestor, provider or admin
        map_user_data[_userId].role = _role;

        if(_role == Role.Provider){
            // Check if user is out of whitelist
            require(!BitMaps.get(providers_whiteList, _userId), "User already whitelisted");
            // Update 2 : set user as whitelisted with BitMaps logic
            BitMaps.setTo(providers_whiteList, _userId, true);
        }

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

    /// @notice get an array of all whitelisted providers inside UserInfo.sol
    /// @return address[] Returns addresses of all UserData whitelisted as providers of this smart contract
    function getProvidersWhitelist() public view returns (address[] memory) {
        uint totalUserCount = _userIds.current();
        uint providerCount = 0;
        uint currentIndex = 0;

        // Count the number of providers
        for (uint i = 0; i < totalUserCount; i++) {
            uint currentId = map_user_data[i + 1].userId;
            if (BitMaps.get(providers_whiteList, currentId)) {
                providerCount += 1;
            }
        }

        // Create an array of addresses for providers
        address[] memory providers = new address[](providerCount);

        // Populate the array with addresses of providers
        for (uint i = 0; i < totalUserCount; i++) {
            uint currentId = map_user_data[i + 1].userId;
            if (BitMaps.get(providers_whiteList, currentId)) {
                address providerAddress = map_user_data[currentId].user_address;
                providers[currentIndex] = providerAddress;
                currentIndex += 1;
            }
        }

        return providers;
    }

    /// @notice Check if the msg.sender is an approved admin (Gasless optimized +++)
    function _checkAdmin() internal view virtual {
        require(map_user_data[map_id[msg.sender]].role == Role.Admin, "Not authorized. Admin only");
    }
    
}