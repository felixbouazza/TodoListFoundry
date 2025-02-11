// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {TaskState} from "../enums/TaskState.sol";

struct Task {
    bytes description;
    TaskState state;
    uint256 createdAt;
}
