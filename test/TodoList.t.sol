// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TodoList} from "../src/TodoList.sol";
import {TaskState} from "../src/enums/TaskState.sol";
import {Task} from "../src/structs/Task.sol";

contract TodoListTest is Test {
    TodoList public todoList;
    uint256 public taskCost;

    event TaskCreated(uint256 indexed taskId);

    function setUp() public {
        todoList = new TodoList();
        taskCost = todoList.taskCost();
    }

    function test_ConstructorDefineOwner() public view {
        assertEq(address(todoList.owner()), address(this));
    }

    function test_CreateTaskWorks() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        vm.expectEmit(true, false, false, false);
        emit TaskCreated(0);
        todoList.createTask{value: taskCost}(taskDescription);
        (bytes memory description, TaskState state) = todoList.getTask(0);
        assertEq(description, taskDescription);
        assertEq(uint256(state), uint256(TaskState.Todo));
    }

    function test_CreateTwoTasksWorks() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        vm.expectEmit(true, false, false, false);
        emit TaskCreated(0);
        todoList.createTask{value: taskCost}(taskDescription);
        (bytes memory description, TaskState state) = todoList.getTask(0);
        assertEq(description, taskDescription);
        assertEq(uint256(state), uint256(TaskState.Todo));

        taskDescription = bytes("Faire les courses");
        vm.expectEmit(true, false, false, false);
        emit TaskCreated(1);
        todoList.createTask{value: taskCost}(taskDescription);
        (description, state) = todoList.getTask(1);
        assertEq(description, taskDescription);
        assertEq(uint256(state), uint256(TaskState.Todo));
    }

    function test_CreateTaskRevertsIfNotEnoughEther() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        vm.expectRevert(TodoList.IncorrectEtherAmount.selector);
        todoList.createTask{value: taskCost - 1}(taskDescription);
    }

    function test_CreateTaskRevertsIfNotOwner() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        vm.expectRevert();
        vm.prank(address(0));
        todoList.createTask{value: taskCost}(taskDescription);
    }
}
