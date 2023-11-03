// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;

/// @title Contract for consensus on scalar value version 2 so S2
/// @author Robert Cowlishaw @0x365, Red Boumghar @redotics
/// @notice You can use this contract for needs of scalar based consensus like a probability
contract ConsensusS2 {

    event NewCDMRequest(CDMRequest new_request);
    event NewCDM(mcdm new_cdm);

    mapping(address => uint) request_nonce;
    mapping(address => mapping(uint => CDMRequest)) requestors_requests;

    // Requestor -> Requestor_Nonce -> provider_address -> mcdm
    // --- This second address works because we can search through the whitelist
    mapping(address => mapping(uint => mapping(address => mcdm))) cdm_provided;

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
    struct mcdm {
        // Probability of collusion
        /*ufixed*/ uint pc;
        // Time to Closest Approach in seconds unix timestamps
        uint tca;
        // Supplier address
        address supplier;
        // stored time
        uint unix_secs;
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
            0,                              // uint request_time_max;
            block.timestamp,                // uint request_time;
            _tca_min,                       // uint tca_min;
            _tca_max,                       // uint tca_max;
            _rso_list                       // string[2] rso_list;
        );
        // Add new CDM Request to requestors list
        requestors_requests[msg.sender][request_nonce[msg.sender]] = new_request;
        // Emit to network
        emit NewCDMRequest(new_request);
        // Increase request count
        request_nonce[msg.sender] += 1;
    }

    function submitData(

    )
        public
    {
        // Create new_object
        // Check if any data exists at cdm_provided[requestor_address][request_nonce][msg.sender]
            // Maybe only pass if data doesnt exist or allow updates to cdm provided
        // add new object to cdm_provided[requestor_address][request_nonce][msg.sender]
        // emit NewCDM
        // Check if all whitelist has been reached or time run out
            // If so then call check_consensus
    }

    


}
