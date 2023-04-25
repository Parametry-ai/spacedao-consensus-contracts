// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;
import "hardhat/console.sol";

/// @title Contract for consensus on scalar value version 1 so S1
/// @author Red Boumghar @redotics
/// @notice You can use this contract for needs of scalar based consensus like a probability
contract ConsensusS1 {
    // when in factory mode: mapping (uint => address) cons2owner;
    // when in factory mode: mapping (address => uint) owner2cons;
    address owner;

    // List of callers authorized to call consensus calculation
    address[] private _authorized_callers;
    // Unix timestamps in second of construction time
    uint private _creation_time;
    string public anything;

    // For the Bayes fusion to function correctly we take care of limits
    ufixed private MAX_PROBABILITY = 0.999999999;
    ufixed private MIN_PROBABILITY;// = 0.000000001;
    uint private CDM_MAX_PAST_AGE;// = 86400; // 1 day in secs

    // ------------- suppliers related variables

    // ------------- CDM related variables
    /// @notice type for a minimum conjunction data message 
    struct mcdm {
        // Probability of collusion
        ufixed pc;
        // Time to Closest Approach in seconds unix timestamps
        uint tca;
        // Supplier address
        address supplier;
        // stored time
        uint unix_secs;
    }

    mapping (string => mcdm[]) req2mcdm;
    mapping (string => address[]) req2supplier;

    /// @notice contains all fields for a proper CDM request
    struct CDMRequest {
        string requester; // to be address
        string issuer; // to be address
        string[3] suppliers_whitelist;
        uint request_time_max;
        uint request_time;
        uint tca_min;
        uint tca_max;
        string[2] rso_list;
    }

    // Mockup event for a request
    event evt_cdm_request(CDMRequest req);
    event evt_insight_received(address supplier, address requester);
    event evt_insight_calculated(string request_id, mcdm);

    mcdm[] public cdms;

    // ------------- CONSENSUS CONTRACT ROUTINES
    /// @param authorized_caller Authorized contract address taht can call the
    ///                          consensus function. The order listens to set
    ///                          data events and trigger consensus when enough
    ///                          suppliers have given insight.
    constructor(address authorized_caller) {
        _owner = msg.sender;
        // we need at least one authorized caller
        _authorized_callers.push(authorized_caller);
        // time in seconds = Math.round(Date.now() / 1000);
    }

    function creation_time() public view returns (uint) {
        return _creation_time;
    }

    // ----------------------------- REQUEST PART
    /// @notice Only emits a request event for mockup purposes 
    function request() public {
        console.log("Request sent at block timestamp is %o", block.timestamp);

        // require(block.timestamp <= certain_time, "You can't call this not, its too late");
        require(msg.sender == owner, "Who are you again?");

        emit evt_cdm_request(
            CDMRequest(
              msg.sender,
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

    // ----------------------------- CONSENSUS PART

    function _is_all_data_here(string request_id) private returns (bool) {
        if (req2supplier[request_id] < supplier_whitelist) {
            return false;
        }
        return true;
    }

    function _this_supplier_belief(address supplier) private returns (ufixed) {
        // mockup, TODO
        return 0.8;
    }

    /// @notice Calculates consensus and only emits a consensus result event for
    ///         mockup purposes 
    /// @param request_id is the hash of the request ID of the requester
    ///                   contract linked to the current consensus contract
    function calculate(string request_id) public returns (mcdm) {
        // TODO check if all data is here

        // Gather confidence models from suppliers
        mapping (address => ufixed) s2belief;
        // Mapping to check last data from supplier 
        mapping (address => uint) s2rtrvd;

        // Gather confidence models from suppliers
        // and prepare Bayes Fusion
        ufixed belief_sum = 0.0;
        for (uint i = 0; i < req2mcdm[request_id].length; i++) {
            // Suppliers can set data several times
            // they are only paid once per request.
            // 100 arbitrarily more than 100 first seconds unix time
            if (s2rtrvd[req2mcdm[request_id][i].supplier] > 100) {
                // replace by latest timestamp if so
                if (req2mcdm[request_id][i].unix_secs >
                    s2rtrvd[req2mcdm[request_id][i].supplier]) {
                    s2rtrvd[req2mcdm[request_id][i].supplier] =
                      req2mcdm[request_id][i].unix_secs;
                }
            } else {
                // belief retrieving function is TODO
                // Belief only depends 
                s2belief[i] =
                  _this_supplier_belief(req2mcdm[request_id][i].supplier);
                belief_sum += s2belief[i];

                s2rtrvd[req2mcdm[request_id][i].supplier] =
                  req2mcdm[request_id][i].unix_secs;
            }
        }

        // Loop over data and establish fusion across 
        //     req2mcdm[request_id].length; i++) {
        //     req2mcdm[request_id][i].pc
        // }

        //emit calculation done
         
    }

    /// @notice set a cdm from a supplier
    /// @dev for now just a bit more than a mockup
    /// @param request_id is the ID of the emitted request that this contract
    ///                   should have listened too and registered. Implicitly
    ///                   contains information about which satellites are
    ///                   involved in the conjunction
    /// @param cdm_pc ufixeding point precision probability for probability of
    ///                collision
    /// @param cdm_tca uint of unix timestamp in seconds
    function set_data(string memory request_id,
                      ufixed cdm_pc,
                      uint cdm_tca) public returns (bool) {
        address supplier_addr = msg.sender;
        uint unix_secs = Math.round(Date.now() / 1000);

        // TODO check inputs
        if (cdm_pc > 1.0 || cdm_pc < 0.0) {
            return false;
        } else {
            if (cdm_pc > MAX_PROBABILITY) {
                cdm_pc = MAX_PROBABILITY;
            }
            if (cdm_pc < MIN_PROBABILITY) {
                cdm_pc = MIN_PROBABILITY;
            }
        }

        if (cdm_tca < unix_secs-CDM_MAX_PAST_AGE) {
            // TCA is a day in the past
            // Consensus won't use it.
            return false;
        }

        // Create entries in local mappings
        // Suppliers can set data several times
        // they are only paid once per request.
        mcdm input = mcdm(cdm_pc, cdm_tca, supplier_addr, unix_secs);
        req2mcdm[request_id].push(input);
        req2supplier[request_id].push(supplier_addr);

        emit evt_insight_received(supplier, requester);
    }


    // --- function set_consensus
}
