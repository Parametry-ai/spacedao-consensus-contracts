// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "./commons.sol";

/// @title Contract for consensus on scalar value version 1 so S1
/// @author Red Boumghar @redotics
/// @notice You can use this contract for needs of scalar based consensus like a probability
contract ConsensusS1 {
    // when in factory mode: mapping (uint => address) cons2owner;
    // when in factory mode: mapping (address => uint) owner2cons;
    address _owner;

    // List of callers authorized to call consensus calculation
    address[] private _authorized_callers;

    // Unix timestamps in second of construction time
    uint private _creation_time;
    string public anything;

    // For the Bayes fusion to function correctly we take care of limits
    /*ufixed*/ uint private MAX_PROBABILITY = 999999999;
    /*ufixed*/ uint private MIN_PROBABILITY = 1;
    uint private CDM_MAX_PAST_AGE;// = 86400; // 1 day in secs

    // ------------- suppliers related variables

    // ------------- CDM related variables
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

    /// @notice this is default template for consensus cdm
    struct ccdm {
        string event_id;
        uint created; // block.timestamp
        uint tca; // CDM timestamp
        /*ufixed*/ uint pc;
        /*ufixed*/ uint distance_m;
        address[2] rsos; // list of involved RSOs
        address[3] sources; // list of data suppliers
        /*ufixed*/ uint consensus_level;
    }

    // Maps requests to arrays of supplier CDMs
    mapping (string => mcdm[]) req2mcdm;
    mapping (string => ccdm) req2ccdm;

    /// @notice contains all fields for a proper CDM request
    struct CDMRequest {
        address requester;
        address issuer;
        string[3] suppliers_whitelist; // list of addresses TODO
        uint request_time_max;
        uint request_time;
        uint tca_min;
        uint tca_max;
        string[2] rso_list;
    }

    // Mockup event for a request
    event evt_cdm_request(CDMRequest req);
    event evt_insight_received(string request_id, mcdm supplier_cdm);
    event evt_insight_calculated(string request_id, ccdm);

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
        require(msg.sender == _owner, "Who are you again?");

        emit evt_cdm_request(
            CDMRequest(
              msg.sender, // TODO
              msg.sender, // TODO
              ["0xAEDE111", "0xAEDE222","0xAEDE333"],
              0,
              0, // now
              1,
              10,
              ["satid1", "satid2"]
            )
        );

        // DEBUG
        calculate("request_id-12345678");
    }

    // Request part manages check if all data as arrived before calling the
    // consensus function
    function _is_all_data_here(string memory request_id, address[] memory min_supplier_list) private returns (bool) {
        // obvious fast check, if we have less replies than suppliers
        // the contract surely need to wait longer
        if (req2mcdm[request_id].length < min_supplier_list.length) {
            return false;
        }

        // if not, then how many unique suppliers do we have:
        uint nb_unique = 0;
        // TODO 10 is a risk if 10 < min_supplier_list.length
        // but this is how I can get things going on.
        // TO BE ROBUSTIFIED
        address[10] memory unique_suppliers;
        for (uint i = 0; i < req2mcdm[request_id].length; i++) {
            // TODO
            if (commons.exists_in_address10array(
                        req2mcdm[request_id][i].supplier,
                        unique_suppliers) == false)
            {
                unique_suppliers[nb_unique] = req2mcdm[request_id][i].supplier;
                nb_unique += 1;
            }


            if (nb_unique >=  min_supplier_list.length)
            {
                return true;
            }
        }

        if (unique_suppliers.length < min_supplier_list.length)
        {
            return false;
        }


        // TODO if all present
        // emit launch_cdm_processing(request_id)
        return true;
    }

    // ----------------------------- CONSENSUS PART
    function _this_supplier_belief(address supplier) private returns (/*ufixed*/ uint) {
        // mockup, TODO
        return 999999998;
    }

    /// @notice Calculates consensus and only emits a consensus result event for
    ///         mockup purposes 
    /// @param request_id is the hash of the request ID of the requester
    ///                   contract linked to the current consensus contract
    function calculate(string memory request_id) public {
        // TODO check if all data is here

        /*********
        // Map confidence models to suppliers
        mapping(address => uint) storage  s2belief;
        // Mapping to check last data from supplier 
        mapping(address => uint) storage s2rtrvd;

        // --- Gather confidence models from suppliers
        // and prepare Bayes Fusion
        //ufixed// uint belief_sum = 0.0;
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
        *********/

        // emit finished calculation
        ccdm memory consensus = ccdm("event-id-81732-0xahudegywde",
        block.timestamp, block.timestamp, 400000, 414, [msg.sender, msg.sender],
        [msg.sender, msg.sender, msg.sender], 600000);
        /*
          "event-id-81732-0xahudegywde",
          block.timestamp, // created
          block.timestamp, // tca
          0.004, // pc
          414.5, // distance_m
          [msg.sender, msg.sender], // rsos
          [msg.sender, msg.sender, msg.sender], // suppliers
          0.6 // consensus_level
        */

        emit evt_insight_calculated(
            request_id,
            consensus
        );
    }

    /// @notice set a cdm from a supplier
    /// @dev for now just a bit more than a mockup
    /// @param request_id is the ID of the emitted request that this contract
    ///                   should have listened too and registered. Implicitly
    ///                   contains information about which satellites are
    ///                   involved in the conjunction
    /// @param cdm_pc /*ufixed*/ uinting point precision probability for probability of
    ///                collision
    /// @param cdm_tca uint of unix timestamp in seconds
    function set_data(string memory request_id,
                      /*ufixed*/ uint cdm_pc,
                      uint cdm_tca) 
             public returns(bool) {
        // Unix time in seconds is block.timestamp

        // --- TODO check if supplier is a registrered supplier
        address supplier_addr = msg.sender;

        // --- TODO check inputs
        if (cdm_pc > 1 || cdm_pc < 999999999) {
            return false;
        } else {
            if (cdm_pc > MAX_PROBABILITY) {
                cdm_pc = MAX_PROBABILITY;
            }
            if (cdm_pc < MIN_PROBABILITY) {
                cdm_pc = MIN_PROBABILITY;
            }
        }

        if (cdm_tca < block.timestamp - CDM_MAX_PAST_AGE) {
            // TCA is a day in the past
            // Consensus won't use it.
            return false;
        }

        // Create entries in local mappings
        // Suppliers can set data several times
        // they are only paid once per request.
        mcdm memory supplier_input = mcdm(cdm_pc, cdm_tca, supplier_addr, block.timestamp);
        req2mcdm[request_id].push(supplier_input);

        emit evt_insight_received(request_id, supplier_input);
        return true;
    }


    // --- function set_consensus
    // TODO
}
