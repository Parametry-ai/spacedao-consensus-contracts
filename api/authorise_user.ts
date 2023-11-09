// SPDX-License-Identifier: LGPL-3.0-or-later

// Notice: Authorise User by ID or Address
// Date: Nov-23
// Author: Robert Cowlishaw @0x365
// Dev: Will automatically overwrite name if it id already exists

import get_dapps from "./commons";

// User defined data
import creds from "./credentials.json";

async function main() {
    // Creates new user or renames current user info at input address
    // Set input parameters
    let tx_params = {
        gasLimit: 30000000
    };
    // Get UserInfo App Object
    let app_UserInfo = await get_dapps("UserInfo", creds.private_key);

    var tx;

    // Address and ID to target
    let address_ = "0x3";
    let id_ = "2";

    // Privilages to set
    let privilage_requestor = true;
    let privilage_provider = true;
    let privilage_admin = true;

    let findByID = true;

    if (findByID) {
        // Find by ID
        let tx = await app_UserInfo.givePrivilages(
            id_,
            privilage_requestor,
            privilage_provider,
            privilage_admin,
            tx_params
        );
    } else {
        // Find by address
        let id_ = await app_UserInfo.whatIsID(address_, tx_params);
        let tx = await app_UserInfo.givePrivilages(
            id_,
            privilage_requestor,
            privilage_provider,
            privilage_admin,
            tx_params
        );
    }
    console.log(tx);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});