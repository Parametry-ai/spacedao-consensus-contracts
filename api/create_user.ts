// SPDX-License-Identifier: LGPL-3.0-or-later

// Notice: Example function that creates a new user on UserInfo dapp
// Date: Nov-23
// Author: Robert Cowlishaw @0x365
// Dev: Will automatically overwrite name if it id already exists

import get_dapps from "./commons";

// User defined data
import creds from "./credentials.json";

async function main() {
    // Creates new user or renames current user info at input address
    // Set input parameters
    let name_ = "TestName"
    let tx_params = {
        gasLimit: 30000000
    };
    // Get UserInfo App Object
    let app_UserInfo = await get_dapps("UserInfo", creds.private_key);

    // Get id from UserInfo App
    let my_id = await app_UserInfo.whatIsMyID(tx_params);
    my_id = Number(my_id)   // Convert from big int to regular int
    // If id == 0 account does not exist
    if (my_id == 0) {
        console.log("Account doesnt exist. Creating new account....")
        let tx = await app_UserInfo.newUser(name_, tx_params);
        console.log(tx);
        // Else account already exists and id was returned
    } else {
        console.log("Account already exists at id=", my_id, ". Changing name on account to", name_)
        let tx = await app_UserInfo.changeName(name_, tx_params);
        console.log(tx);
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});