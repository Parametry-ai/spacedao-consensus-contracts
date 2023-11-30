// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;

import "./UserInfo.sol";
import "./Reputation.sol";
import "./commons.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";


/// @title Contract for consensus on scalar value version 2 so S2
/// @author Robert Cowlishaw @0x365, Red Boumghar @redotics
/// @notice You can use this contract for needs of scalar based consensus like a probability
/// @dev WIP --- Input validation is required throughout
contract ConsensusS2 {

    using SafeMath for uint256;
    using commons for *;

    UserInfo public userInfoApp;
    Reputation public reputationApp;

    uint64 public REQUEST_TIMEOUT = 1000;
    uint public threshold = 75; // Example: 75%-probabilty of collision to find a consensus

    event NewCDMRequest(CDMRequest new_request);
    event NewCDM(MCDM new_cdm);
    event NewConsensusResult(ConsensusResult new_consensus);

    mapping(address => uint) request_nonce;
    mapping(address => mapping(uint => CDMRequest)) requests;

    // Requestor -> Requestor_Nonce -> provider_address -> mcdm
    // --- This second address works because we can search through the whitelist
    mapping(address => mapping(uint => mapping(address => MCDM))) cdm_provided;
    // List of cdm providers for specific request
    mapping(address => mapping(uint => address[])) cdm_providers;

    /// @notice contains all fields for a proper CDM request
    struct CDMRequest {
        address requester;  // msg.sender
        address issuer;     // msg.sender
        address[3] suppliers_whitelist; // list of addresses TODO
        uint request_time_max;  // ?
        uint request_time;  // Time Now
        uint tca_min;       // Time input
        uint tca_max;       // Time input 2
        string[2] rso_list; // Sat Data
    }
    
    /// @notice type for a minimum conjunction data message 
    struct MCDM {
        // Probability of collusion
        /*ufixed*/ uint pc;
        // Time to Closest Approach in seconds unix timestamps
        uint tca;
        // Supplier address
        address supplier;
        // stored time
        uint unix_secs;
    }

    /// @notice type for a consensus result
    /// @dev WIP
    struct ConsensusResult {
        address temp;
    }

    /// @notice Gets app address of a deployed UserInfo contract
    /// @param _userInfoAppAddress Address of deployed UserInfo contract
    constructor (
        address _userInfoAppAddress,
        address _reputationAppAddress
    ) {
        userInfoApp = UserInfo(_userInfoAppAddress);
        reputationApp = Reputation(_reputationAppAddress);
        /// --- This can now be called to access the user info contract
    }

    /// @notice New Data Request ending in emit event
    /// @dev WIP --- Some CDM Request data is missing
    function newDataRequest(
        address[3] memory _suppliers_whitelist,
        uint _tca_min,
        uint _tca_max,
        string[2] memory _rso_list
    ) 
        public
    {
        // WIP --- Check input data
        
        // Create new CDM Request
        CDMRequest memory new_request = CDMRequest(
            msg.sender,                     // address requester;
            msg.sender,                     // address issuer;
            _suppliers_whitelist,           // string[3] suppliers_whitelist;
            REQUEST_TIMEOUT,                // uint request_time_max;
            block.timestamp,                // uint request_time;
            _tca_min,                       // uint tca_min;
            _tca_max,                       // uint tca_max;
            _rso_list                       // string[2] rso_list;
        );
        // Add new CDM Request to requestors list
        requests[msg.sender][request_nonce[msg.sender]] = new_request;
        // Increase request count
        request_nonce[msg.sender] += 1;
        // Emit to network
        emit NewCDMRequest(new_request);
        
    }

    /// @notice Adds new cdm data from provider
    /// @dev Entry point for checkConsensus
    /// @param _target_address Address of the requestor
    /// @param _target_nonce The nonce of the the request for the specific requestor
    /// @param _pc Probability of collision
    /// @param _tca Time of closest approach
    function submitData(
        address _target_address,
        uint _target_nonce,
        uint _pc,
        uint _tca
    )
        public
    {
        // WIP --- Check data input

        // Check if msg.sender has already provided data (cdm_provided at msg.sender exists)
            // Maybe only pass if data doesnt exist or allow updates to cdm provided
        // assert(cdm_provided[_target_address][_target_nonce][msg.sender].unix_secs != 0);
        // Replace assert by require
        // require(cdm_provided[_target_address][_target_nonce][msg.sender].unix_secs == 0, "Data already submitted");

        // Create new_object
        MCDM memory new_cdm = MCDM(
            _pc,                                // uint pc;
            _tca,                               // uint tca;
            msg.sender,                        // address supplier;
            block.timestamp                    // uint unix_secs;
        ); 
        // add new object to cdm_provided[requestor_address][request_nonce][msg.sender]
        cdm_provided[_target_address][_target_nonce][msg.sender] = new_cdm;
        cdm_providers[_target_address][_target_nonce].push(msg.sender);
        
        if (_checkTimeout(_target_address, _target_nonce)) {
            // If request timed_out
            checkConsensus();
        } else if (checkWhitelist(_target_address, _target_nonce)) {
            // Check if all whitelist has been reached (if all whitelist in cdm_providers list)
            checkConsensus();
        }
        // (ideally put events in the end of function to prevent reentrancy attacks)
        // emit NewCDM 
        // WIP --- Want to add more data so you can see what satellites and what
        emit NewCDM(new_cdm);

    }

    /// @notice Checks if request has timed out
    /// @param _target_address Address of the requestor
    /// @param _target_nonce The nonce of the the request for the specific requestor
    /// @return bool Returns true or false if request has timed out
    function _checkTimeout(
        address _target_address,
        uint _target_nonce
    )
        public
        view
        returns (bool)
    {
        if (block.timestamp > requests[_target_address][_target_nonce].request_time + requests[_target_address][_target_nonce].request_time_max) {
            return true;
        } else {
            return false;
        }
    }

    /// @notice Checks if full whitelist has been completed
    /// @param _target_address Address of the requestor
    /// @param _target_nonce The nonce of the the request for the specific requestor
    /// @return bool true or false if whitelist completed
    function checkWhitelist(
        address _target_address,
        uint _target_nonce
    )
        public
        view
        returns (bool)
    {
        address[3] memory whitelist = requests[_target_address][_target_nonce].suppliers_whitelist;
        for (uint i=0; i<whitelist.length; i++) {
            if (cdm_provided[_target_address][_target_nonce][whitelist[i]].unix_secs == 0) {
                return false;
            }
        }
        return true;
    }

    /// @notice Calls checkConsensus if timed out
    /// @dev Entry point for checkConsensus
    /// @param _target_address Address of the requestor
    /// @param _target_nonce The nonce of the the request for the specific requestor
    function forceTimeout(
        address _target_address,
        uint _target_nonce
    )
        public
    {
        // Assert request has timed out
        assert(_checkTimeout(_target_address, _target_nonce));
        // Check if logic is safe changing assert by require
        // require(_checkTimeout(_target_address, _target_nonce), "Request has not timed out");
        checkConsensus();
    }

    /// @notice Checks the consensus score
    /// @dev Must only be called from inside contract to reduce asserts
    function checkConsensus(_target_address, _target_nonce) 
        internal
    {
        // WIP --- NEED TO KNOW HOW CONSENSUS WILL BE REACHED

        // First example :
        uint totalPoviders = cdm_provided[_target_address][_target_nonce].length;
        uint consensusCount = 0;
        
        for(uint i = 0; i < totalProviders; i++){
            address provider = cdm_provided[_target_address][_target_nonce][i];
            MCDM storage data = cdm_provided[_target_address][_target_nonce][provider];
        
            // Add your consensus logic here.
            // For example, check if the collision probability (pc) is above a certain threshold.

            if (data.pc >= threshold) {
                consensusCount++;
            }
        }

         // Check if consensus is reached (e.g., majority agrees on collision)
        if (consensusCount > totalProviders / 2) {
            // Consensus reached, take appropriate action.
            // This might involve triggering alerts, updating a status, or other actions based on your specific use case.
            emit NewConsensusResult(ConsensusResult(msg.sender));
            // Additional logic based on consensus reached.
        }

        }
}
