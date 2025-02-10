// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TodoList} from "../src/TodoList.sol";

contract TodoListTest is Test {
    TodoList public todoList;

    function setUp() public {
        todoList = new TodoList();
    }
}
