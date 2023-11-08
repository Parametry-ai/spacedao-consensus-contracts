# Basic script to get the dapp address for consensus and append it to config.json file
# Not to be in final version (Just useful for development)

import json
import os

def load_json(file_name):
    with open(file_name) as f:
        output = json.load(f)
    return output

def save_json(file_name, data):
    with open(file_name,'w') as f:
        json.dump(data, f)


# Input path
input_path = ["..", "dapp", "dapp_ConsensusS2.json"]
# Output
output_path = ["config.json"]


# Real paths
path_in = os.path.dirname(os.path.abspath(__file__))
for i in range(len(input_path)):
    path_in = os.path.join(path_in, input_path[i])
path_out = os.path.dirname(os.path.abspath(__file__))
for i in range(len(output_path)):
    path_out = os.path.join(path_out, output_path[i])

# Get address
dapp_address = load_json(path_in)["dapp_address"]

# Load output
output_data = load_json(path_out)
output_data["AppAddress"]["Consensus"] = dapp_address
save_json(path_out, output_data)