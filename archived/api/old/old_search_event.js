const { Web3 } = require('web3');
const fs = require("fs");
const path = require("path");

// WIP
// Gets all events for specific contract
// Change to subscription model for a proper api


// Custom imports
var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545'));
const dapp_data = require("../dapp/dapp-data.json");

// Converts bigint values into strings as json doesnt like bigint
function toObject(stuff) {
  return JSON.parse(JSON.stringify(stuff, (key, value) =>
      typeof value === 'bigint'
          ? value.toString()
          : value // return everything else unchanged
  ));
}

// Will save in this api file
save_file_name = "allEvents.json"

// Gets all events from the specific contract
async function main() {  

  // Set contract to get events from
  var contract = new web3.eth.Contract(dapp_data.abi, dapp_data.dapp_address);

  // Get all events
  contract.getPastEvents('allEvents', {
    filter: {},
    fromBlock: 0,
    toBlock: 'latest'
  }, function(error, events){ console.log(events); })
  .then(function(events){
    var important_data = []
    // Remove duplicate fields and unrequired data
    for (i=0;i<events.length;i++) {
      for (j=0;j<events[i].returnValues.new_request.__length__;j++) {
        delete events[i].returnValues.new_request[j.toString()]
      }
      important_data.push(events[i].returnValues.new_request)
    }
    // Write to json file
    fs.writeFileSync(
      path.join(__dirname, save_file_name),
      JSON.stringify(toObject(important_data), undefined, 2)
    );
  });
}




// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});