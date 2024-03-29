// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import {SpaceDAOID} from "./SpaceDAOID.sol";
import {Counters} from "@openzeppelin-v4/contracts/utils/Counters.sol";

/// @title Contract for managing consensus on conjunction data messages in the space domain
/// @author Antoine Delamare

contract ConsensusCDM {

    // openzeppelin's secure increment smart contract
    using Counters for Counters.Counter; 

    SpaceDAOID public id_app;

    address immutable private consensusOwner;
    Counters.Counter private _nonceIds;

    // State variables
    uint256 public constant REQUEST_TIMEOUT = 1 days; // Maximum timeout for a request

    // Enum to define the state of a request
    enum RequestState { Pending, Approved, Rejected }

    // Struct to store request details
    /// @notice contains all fields for a proper CDM request
    struct CDMRequest {
        uint256 nonce; // nonce of the request
        address requestor;  // requestor address
        address[3] providers_whitelist;     // provider whitelist (3 of the minimum consensus)
        uint request_time_max;  // maximum time for request to find a consensus
        uint request_time;  // initiation time of request (block.timestamp)
        uint tca_min;       // minimum time of closest approach
        uint tca_max;       // Maximum time of closest approach
        string[2] rso_list; // Description of 2 RSO about to collide
        RequestState state; // State of the request
    }
    
    /// @notice type for a minimum conjunction data message 
    struct MCDM {
        uint256 nonce; // nonce of the request
        uint pc;  // Probability of collusion
        uint tca; // Time to Closest approach in seconds unix timestamps
        address provider; // Provider address
        uint timestamp; // stored time of request
        RequestState state; // State of the request
    }

    // MAPPINGS
    // Mapping to store details of each CDMrequest (indexed by requestor and request_nonce)
    mapping(address => mapping(uint256 => CDMRequest)) private CDMrequests;
    // Mapping to store details of each MCDM (indexed by request_nonce and provider_address)
    mapping(uint256 => mapping(address => MCDM)) private MCDMRequests;
   
    // Events
    event newRequest(address indexed requestor, uint indexed nonce);
    event DataSubmission(address indexed provider, address indexed requestor, uint indexed nonce);
    event NewCDM(MCDM new_cdm);
    

    // ----------------------------------------------------- CONSTRUCTOR
    constructor(address _userInfoAppAddress) {
        consensusOwner = msg.sender;
        id_app = SpaceDAOID(_userInfoAppAddress);
    }


    /// @notice Function to make a data request for objects that a single satellite might collide with
    /// @param _tca_min Start of time window to search for satellite conjunctions within
    /// @param _tca_max End of time window to search for satellite conjunctions within
    /// @param _rso_list 2 length string array with first string the rso object and second string "BLANK"
    /// WIP - Need to create the consensus
    function requestData(uint _tca_min, uint _tca_max, string[2] memory _rso_list, address[3] memory _providers_whitelist) external returns(uint256) {
        // Validate parameters
        require(_tca_max >= _tca_min, "Invalid TCA parameters");
        // Check second argument in _rso_single is "BLANK"
        require(keccak256(abi.encodePacked(_rso_list[0])) != keccak256(""), "At least 1 RSO, first in the list, should be specified");
        
        // Increment nonce
        _nonceIds.increment();
        uint256 actualNonce = _nonceIds.current();

        // TODO: check if providers in the whitelist have a valid SpaceDAOID.
    
        // Store the request details
        CDMrequests[msg.sender][actualNonce] = CDMRequest({
            nonce: actualNonce,
            requestor: msg.sender,
            providers_whitelist: _providers_whitelist,
            request_time_max: block.timestamp + REQUEST_TIMEOUT,
            request_time: block.timestamp,
            tca_min: _tca_min,
            tca_max: _tca_max,
            rso_list: _rso_list,
            state: RequestState.Pending
        });

        // Emit event
        emit newRequest(msg.sender, actualNonce);
        return actualNonce;
    }


    /// @notice Function for the provider to submit data for a request
    function submit(address _requestor_address, uint256 _request_nonce, uint256 _pc, uint256 _tca) external {
        CDMRequest storage request = CDMrequests[_requestor_address][_request_nonce];
        // Check if the request is valid and in a pending state
        require(request.state == RequestState.Pending, "Invalid request state");

        // Validate parameters
        require(_tca >= request.tca_min && _tca <= request.tca_max, "Invalid TCA parameter");
        require(_pc <= 100, "Invalid PC parameter");

        // // Calculate reliability threshold based on provider's reliability
        // uint256 reliabilityThreshold = (userInfoApp.map_user_data[userInfoApp.map_id[msg.sender]].reliability);

        // // Check if the reliability threshold is met
        // require(_pc <= reliabilityThreshold, "Insufficient reliability for data submission");

        // Store the minimum conjunction data message
        MCDMRequests[_request_nonce][msg.sender] = MCDM({
            nonce: _request_nonce,
            pc: _pc,
            tca: _tca,
            provider: msg.sender,
            timestamp: block.timestamp,
            state: RequestState.Approved
        });

        // Update the request state to Approved
        request.state = RequestState.Approved;
    
        // Emit event
        emit DataSubmission(msg.sender, request.requestor, _request_nonce);
    }


}
