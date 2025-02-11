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
    event TaskUpdated(uint256 indexed taskId);
    event TaskDeleted(uint256 indexed taskId);
    event TaskIdMoved(uint256 fromId, uint256 toId);

    function setUp() public {
        todoList = new TodoList();
        taskCost = todoList.taskCost();
    }

    function test_Constant_Defines() public view {
        assertEq(todoList.taskCost(), 0.01 ether);
    }

    function test_Constructor_DefineOwner() public view {
        assertEq(address(todoList.owner()), address(this));
    }

    function test_CreateTask_Works() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        vm.expectEmit(true, false, false, false);
        emit TaskCreated(0);
        todoList.createTask{value: taskCost}(taskDescription);
        (bytes memory description, TaskState state) = todoList.getTask(0);
        assertEq(description, taskDescription);
        assertEq(uint256(state), uint256(TaskState.Todo));
    }

    function test_CreateTasks_TwoTasksWorks() public {
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

    function test_CreateTask_Reverts_IfNotEnoughEther() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        vm.expectRevert(TodoList.IncorrectEtherAmount.selector);
        todoList.createTask{value: taskCost - 1}(taskDescription);
    }

    function test_CreateTask_Reverts_IfNotOwner() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        vm.expectRevert();
        vm.prank(address(0));
        todoList.createTask{value: taskCost}(taskDescription);
    }

    function test_GetTask_Works() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        todoList.createTask{value: taskCost}(taskDescription);
        (bytes memory description, TaskState state) = todoList.getTask(0);
        assertEq(description, taskDescription);
        assertEq(uint256(state), uint256(TaskState.Todo));
    }

    function test_GetTask_WithTwoTasksWorks() public {
        bytes memory firstTaskDescription = bytes("Sortir le chien");
        todoList.createTask{value: taskCost}(firstTaskDescription);
        bytes memory secondtaskDescription = bytes("Faire les courses");
        todoList.createTask{value: taskCost}(secondtaskDescription);
        (bytes memory description, TaskState state) = todoList.getTask(0);
        assertEq(description, firstTaskDescription);
        assertEq(uint256(state), uint256(TaskState.Todo));
        (description, state) = todoList.getTask(1);
        assertEq(description, secondtaskDescription);
        assertEq(uint256(state), uint256(TaskState.Todo));
    }

    function test_GetTask_Reverts_IfNotExists() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x32));
        todoList.getTask(0);
    }

    function test_GetTask_Reverts_IfNotOwner() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        todoList.createTask{value: taskCost}(taskDescription);
        vm.expectRevert();
        vm.prank(address(0));
        todoList.getTask(0);
    }

    function test_GetTasks_EmptyTasks() public {
        uint256[] memory ids = todoList.getTasks();
        assertEq(ids.length, 0);
    }

    function test_GetTasks_OneElement() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        todoList.createTask{value: taskCost}(taskDescription);
        uint256[] memory ids = todoList.getTasks();
        assertEq(ids.length, 1);
        assertEq(ids[0], 0);
    }

    function test_GetTasks_TwoElements() public {
        bytes memory firstTaskDescription = bytes("Sortir le chien");
        todoList.createTask{value: taskCost}(firstTaskDescription);
        bytes memory secondtaskDescription = bytes("Faire les courses");
        todoList.createTask{value: taskCost}(secondtaskDescription);
        uint256[] memory ids = todoList.getTasks();
        assertEq(ids.length, 2);
        assertEq(ids[0], 0);
        assertEq(ids[1], 1);
    }

    function test_GetTasks_Reverts_IfNotOwner() public {
        vm.expectRevert();
        vm.prank(address(0));
        todoList.getTasks();
    }

    function test_UpdateTask_Works() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        todoList.createTask{value: taskCost}(taskDescription);
        vm.expectEmit(true, false, false, false);
        emit TaskUpdated(0);
        bytes memory newTaskDescription = bytes("Faire les courses");
        todoList.updateTask(0, newTaskDescription, TaskState.Doing);
        (bytes memory description, TaskState state) = todoList.getTask(0);
        assertEq(description, newTaskDescription);
        assertEq(uint256(state), uint256(TaskState.Doing));
    }

    function test_UpdateTask_Reverts_IfNotExists() public {
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x32));
        todoList.updateTask(0, bytes("Sortir le chien"), TaskState.Doing);
    }

    function test_UpdateTask_Reverts_IfNotOwner() public {
        bytes memory taskDescription = bytes("Sortir le chien");
        todoList.createTask{value: taskCost}(taskDescription);
        vm.expectRevert();
        vm.prank(address(0));
        todoList.updateTask(0, taskDescription, TaskState.Doing);
    }
}
