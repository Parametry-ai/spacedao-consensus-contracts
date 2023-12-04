// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;

import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

/// @title Contract for storing permissions and information of users
/// @author Antoine Delamare
/// @dev WIP --- check if rating logic & newUser whitelist creation convenient | add a merkleProof verification for the whitelist logic
contract UserInfo {

    using Counters for Counters.Counter; // openzeppelin's secure increment smart contract
    using SafeMath for uint256; // openzeppelin's secure arithmetic operations smart contract

    // @notice adminOwner = owner of this smart contract
    address private immutable adminOwner;

    // @notice Counter of userIds
    Counters.Counter private _userIds;

    /// Companies whitelist (Gasless optimized +++)
    /// @notice one user initiated as whitelisted with his _userId (gasless alternative to mapping)
    BitMaps.BitMap private _whiteList;
    // @dev Library for managing uint256 to bool mapping in a compact and efficient way, provided the keys are sequential.
    // Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
    // BitMaps pack 256 booleans across each bit of a single 256-bit slot of uint256 type.
    // Hence booleans corresponding to 256 sequential indices would only consume a single slot,
    // unlike the regular bool which would consume an entire slot for a single value.
    // This results in gas savings in two ways:
    // 1) Setting a zero value to non-zero only once every 256 times
    // 2) Accessing the same warm slot for every 256 sequential indices


    // ROLES OF USER
    enum Role {None, Requestor, Provider, Admin}

    // Map user address to id values
    mapping (address => uint) map_id;
    // Map id value to all user data
    mapping (uint => UserData) map_user_data;
    // Map id User => id Rating => Rating
    mapping(uint => mapping(uint => Rating)) map_user_ratings;
    
    // Struct User
    struct UserData {
        uint256 userId; // id of the user
        address user_address; // address of the user
        uint totalReputation; // average user rating
        uint numRatings; // number of ratings for the user
        string name; // name of the user
        uint creation_time; // timestamp of the creation
        Role role; // Role of the user (initiated at None for all users, excepting adminOwner)
    }

    // Struct rating (for one User)
    struct Rating {
        uint256 ratingId; // id of the rating
        address rater; // Address of the rater
        uint256 value; // value of the rating (between 1 to 5)
        string comment; // comment of the rating
    }

    // EVENTS
    event UserReputationChanged(uint indexed userId, uint newReputation);
    event UserRated(uint indexed userId, address indexed rater, uint indexed rating, uint value, string comment);
    
    /// @notice Give first deployer admin privilages and userId 1
    /// @param _name Name that user would like on profile
    constructor (
        string memory _name
    ) {
        adminOwner = msg.sender; // AdminOwner immutable initiated
        newUser(_name); // First user adminOwner (Role.Admin) initiated
    }

    /// @notice modifier for admin user (Gasless optimized +++)
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
        // Give address new id
        _userIds.increment();
        uint newUserId = _userIds.current();
        map_id[msg.sender] = newUserId;

        // Give id new user data
        Role initialRole = (msg.sender == adminOwner) ? Role.Admin : Role.None;

        // Give id new user data
        map_user_data[newUserId] = UserData({
            userId: newUserId,
            user_address: msg.sender,
            name: _name,
            totalReputation: 0,
            numRatings: 0,
            creation_time: block.timestamp,
            role: initialRole
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

    /// @notice Change info that doesnt require admin privaliges
    /// @param _name New name that user would like on profile
    /// @dev WIP --- is the require logic of check if an user is Role.None correctly implementated ?
    function changeName (
        string memory _name
    )
        external
    {
        require(map_user_data[map_id[msg.sender]].role != Role.None, "Not authorized. Only attributed Roles can change their names");
        map_user_data[map_id[msg.sender]].name = _name;
    }

    /// @notice Change privilages of the target id if caller is admin (Gasless optimized +++)
    /// @param _userId | add _userId to whitelist and change privilages from Role.None to Role.Requestor, Role.Provider or Role.Admin
    /// @dev WIP --- if validated, need to add a MerkleProof logic to secure the whitelist
    function givePrivilages (
        uint _userId,
        Role _role
    ) 
        external onlyAdmin
    {
        // Check if userId already created
        require(_userId <= _userIds.current(), "Invalid target user ID");
        // Check if role of userId is None
        require(uint(_role) == 0, "New role must be at least None to be changed");
        // Check if user is out of whitelist
        require(!BitMaps.get(_whiteList, _userId), "User already whitelisted");

        // UPDATES
        // Update 1 : privilages of input user changed to requestor, provider or admin
        map_user_data[_userId].role = _role;

        // Update 2 : set user as whitelisted with BitMaps logic
        BitMaps.setTo(_whiteList, _userId, true);
        
    }

    /// @notice Check if address is approved for requestor and provider(
    /// @param _user_address The address to check
    /// @return Role Returns role of an user Role.None, Role.Admin, Role.Provider of Role.Requestor
    function checkAddressRole(address _user_address) public view returns (Role) {
        return map_user_data[map_id[_user_address]].role;
    }
    
    /// @notice Check if id is approved for requestor and provider(
    /// @param _userId The id to check
    /// @return Role Returns role of an user Role.None, Role.Admin, Role.Provider of Role.Requestor
    function checkIdRole(uint _userId) public view returns (Role) {
        return map_user_data[_userId].role;
    }

    /// @notice Check reputation of an approved user
    /// @param _userId The id to check
    /// @return uint Returns average rating of one user (with _userId)
    function getReputation(uint _userId) external view returns (uint) {
    return map_user_data[_userId].numRatings > 0
        ? SafeMath.div(map_user_data[_userId].totalReputation, map_user_data[_userId].numRatings)
        : 0;
    }

    /// @notice Rate an approved user
    /// @param _userId The id to check, _value the rating value to put (between 1 to 5), _comment the comment to review
    /// @dev WIP --- is the rating logic convenient ?
    function rateUser(uint _userId, uint _value, string calldata _comment) external {
        // Check if user has a role different to Role.None
        require(uint(map_user_data[_userId].role) > 0 ,"User with Role.None cannot be reviewed");
        // Check if user is inside the BitMaps whitelist (true if whitelisted, false if not)
        require(BitMaps.get(_whiteList, _userId), "User not whitelisted");
        // Check if rating value is a uint between 1 and 5
        require(_value >= 1 && _value <= 5, "Invalid rating value. Should be between 1 and 5.");
         // Check if rating comment is not null
        require(bytes(_comment).length > 0, "Comment cannot be empty.");

        // Incrementation of the ratingId
        uint newRatingId = map_user_data[_userId].numRatings; // Use numRatings to ID the rating
        // Updating rating mapping
        map_user_ratings[_userId][newRatingId] = Rating({
            ratingId: newRatingId,
            rater: msg.sender,
            value: _value,
            comment: _comment
        });
        // Updating user ratings properties mapping
        map_user_data[_userId].totalReputation = SafeMath.add(map_user_data[_userId].totalReputation, _value);
        map_user_data[_userId].numRatings = SafeMath.add(map_user_data[_userId].numRatings, 1);

        emit UserRated(_userId, msg.sender, newRatingId, _value, _comment);
        emit UserReputationChanged(_userId, map_user_data[_userId].numRatings > 0
            ? SafeMath.div(map_user_data[_userId].totalReputation, map_user_data[_userId].numRatings)
            : 0
        );
    }

    /// @notice Check if the msg.sender is an approved admin (Gasless optimized +++)
    function _checkAdmin() internal view virtual {
        require(map_user_data[map_id[msg.sender]].role == Role.Admin, "Not authorized. Admin only");
    }

}
