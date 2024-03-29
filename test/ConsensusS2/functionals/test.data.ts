import key_to_signer from "./test.key_converter"
import def_k from "../../default_hardhat_keys.json"

// All the input data for testing
const all_data = {
  "new_data_requests_list": [
    {
      "caller": key_to_signer(def_k.private_key_list[1]),
      "caller_pub": def_k.public_key_list[1],
      "input_data": [231, 3000000000, ["ksdf", "sadg"], [def_k.public_key_list[2], def_k.public_key_list[3], def_k.public_key_list[4]]],
      "tx_params": {gasLimit: 30000000}
    },
    {
      "caller": key_to_signer(def_k.private_key_list[2]),
      "caller_pub": def_k.public_key_list[2],
      "input_data": [543, 563, ["adwf", "fdbs"], [def_k.public_key_list[1], def_k.public_key_list[3], def_k.public_key_list[4]]],
      "tx_params": {gasLimit: 30000000}
    },
    {
      "caller": key_to_signer(def_k.private_key_list[3]),
      "caller_pub": def_k.public_key_list[3],
      "input_data": [345, 3424, ["bfs", "qwet"], [def_k.public_key_list[1], def_k.public_key_list[2], def_k.public_key_list[4]]],
      "tx_params": {gasLimit: 30000000}
    },
    {
      "caller": key_to_signer(def_k.private_key_list[4]),
      "caller_pub": def_k.public_key_list[4],
      "input_data": [654, 765, ["lghfn", "nhrtv"], [def_k.public_key_list[1], def_k.public_key_list[2], def_k.public_key_list[3]]],
      "tx_params": {gasLimit: 30000000}
    }
  ],
  "new_cdm_submit": [
    {
      "caller": key_to_signer(def_k.private_key_list[2]),
      "caller_pub": def_k.public_key_list[2],
      "input_data": [def_k.public_key_list[1], 1, 65, 48325],
      "tx_params": {gasLimit: 30000000}
    },
    {
      "caller": key_to_signer(def_k.private_key_list[5]),
      "caller_pub": def_k.public_key_list[5],
      "input_data": [def_k.public_key_list[1], 0, 34, 543],
      "tx_params": {gasLimit: 30000000}
    },
    {
      "caller": key_to_signer(def_k.private_key_list[3]),
      "caller_pub": def_k.public_key_list[3],
      "input_data": [def_k.public_key_list[1], 0, 23, 4533],
      "tx_params": {gasLimit: 30000000}
    },
    {
      "caller": key_to_signer(def_k.private_key_list[4]),
      "caller_pub": def_k.public_key_list[4],
      "input_data": [def_k.public_key_list[1], 0, 61, 4533],
      "tx_params": {gasLimit: 30000000}
    }
  ]
}


// Returns data
function get_data(list_name: string) {
  if (list_name == "new_data_requests_list") {
    return all_data.new_data_requests_list;
  } else if (list_name == "new_cdm_submit") {
    return all_data.new_cdm_submit;
  } else {
    throw("Remember to add new data at get_data function as well as all data variable")
  }
  
}

export=get_data;