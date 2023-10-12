// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.9;

library commons {
    function exists_in_address10array(address in_obj1, address[10] memory in_array) internal pure returns (bool) {
        for (uint i = 0; i < in_array.length; i++) {
            if (in_array[i] == in_obj1) {
                return true;
            }
        }
        return false;
    }
}
