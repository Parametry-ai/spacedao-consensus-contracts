// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;
import "hardhat/console.sol";

/// @title Contract for consensus on scalar value version 1 so S1
/// @author Red Boumghar @redotics
/// @notice You can use this contract for needs of scalar based consensus like a probability
contract ConsensusS1 {
    address owner;
    string public anything;


    // ------------- providers related variables

    // ------------- CDM related variables
    /// @notice type for a conjunction data message 
    struct CDM {
        string id;
        // Time to Closest Approach in seconds unix timestamps
        uint tca;
        string[] rso_list;
    }

    /// @notice contains all fields for a proper CDM request
    struct CDMRequest {
        string requester; // to be address
        string issuer; // to be address
        string[3] providers_whitelist;
        uint request_time_max;
        uint request_time;
        uint tca_min;
        uint tca_max;
        string[2] rso_list;
    }

    // Mockup event for a request
    event CDMRequest_event(CDMRequest req);

    // ------------- CDM related variables
    constructor() {
        owner = msg.sender;
        // time in seconds = Math.round(Date.now() / 1000);
    }

    /// @notice Only emits a request event for mockup purposes 
    function request() public {
        console.log("Request sent at block timestamp is %o", block.timestamp);

        // require(block.timestamp <= certain_time, "You can't call this not, its too late");
        require(msg.sender == owner, "Who are you again?");

        emit CDMRequest_event(
            CDMRequest(
              "0xAAA",
              "0xCCC",
              ["0xAEDE111", "0xAEDE222","0xAEDE333"],
              0,
              0, // now
              1,
              10,
              ["satid1", "satid2"]
            )
        );
    }

    /// @notice Only emits a consensus result event for mockup purposes 
    function result() public {
        //emit CDMRequest_event(A);
         
    }

    /// @notice set a cdm from a provider
    /// @dev for now just a mockup
    function set_cdm(string memory provider_addr, string memory cdm) public {
      anything = provider_addr;
      if (true) {
          anything = cdm;
          return result();
      }
    }
}
