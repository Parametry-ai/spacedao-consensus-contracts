// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;

/// @title Contract for consensus on scalar value version 2 so S2
/// @author Robert Cowlishaw @0x365
/// @notice You can use this contract for needs of scalar based consensus like a probability
contract ConsensusS2 {
    // State variables
    // uint256 public myNumber;

    // Events - to log and track important contract activities
    // event NumberSet(uint256 newNumber, address caller);

    // Constructor - gets executed once at contract deployment
    // constructor() {
        // myNumber = 0;
        // myAddress = msg.sender;
    // }

    // Function to set the 'myNumber' variable
    // function setNumber(uint256 _newNumber) public {
    //     myNumber = _newNumber;
    //     emit NumberSet(_newNumber, msg.sender);
    // }

    event NewCDMRequest(CDMRequest new_request);

    mapping(address => uint) requests_count;
    mapping(address => CDMRequest[]) requestors_requests;

    /// @notice contains all fields for a proper CDM request
    struct CDMRequest {
        address requester;  // msg.sender
        uint nonce;         // requests_count
        address issuer;     // msg.sender
        address[3] suppliers_whitelist; // list of addresses TODO
        uint request_time_max;  // ?
        uint request_time;  // Time Now
        uint tca_min;       // Time input
        uint tca_max;       // Time input 2
        string[2] rso_list; // Sat Data
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
            msg.sender,     // address requester;
            requests_count[msg.sender],     // uint nonce;
            msg.sender,     // address issuer;
            _suppliers_whitelist,   // string[3] suppliers_whitelist;
            0,                // uint request_time_max;
            block.timestamp,                // uint request_time;
            _tca_min,                // uint tca_min;
            _tca_max,                // uint tca_max;
            _rso_list                // string[2] rso_list;
        );
        // Add new CDM Request to requestors list
        requestors_requests[msg.sender].push(new_request);
        // Emit to network
        emit NewCDMRequest(new_request);
        // Increase request count
        requests_count[msg.sender] += 1;
    }

    


}
