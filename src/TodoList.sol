// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Task} from "./structs/Task.sol";
import {TaskState} from "./enums/TaskState.sol";
import {console} from "forge-std/Test.sol";

contract TodoList {
    address public immutable owner;
    uint256 public constant taskCost = 0.01 ether;
    Task[] private tasks;

    event TaskCreated(uint256 indexed taskId);
    event TaskUpdated(uint256 indexed taskId);
    event TaskDeleted(uint256 indexed taskId);
    event TaskIdMoved(uint256 fromId, uint256 toId);

    error Unauthorized();
    error IncorrectEtherAmount();

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createTask(bytes calldata description) external payable onlyOwner {
        if (msg.value != taskCost) {
            revert IncorrectEtherAmount();
        }

        tasks.push(Task(description, TaskState.Todo, block.timestamp));
        emit TaskCreated(tasks.length - 1);
    }

    function getTask(uint256 taskId) external view onlyOwner returns (bytes memory description, TaskState state) {
        return (tasks[taskId].description, tasks[taskId].state);
    }

    function getTasks() external view onlyOwner returns (uint256[] memory ids) {
        ids = new uint256[](tasks.length);
        for (uint256 i = 0; i < tasks.length; i++) {
            ids[i] = i;
        }
        return ids;
    }

    function updateTaskDescription(uint256 taskId, bytes calldata description) external onlyOwner {
        tasks[taskId].description = description;
        emit TaskUpdated(taskId);
    }

    function updateTaskState(uint256 taskId, TaskState state) external onlyOwner {
        tasks[taskId].state = state;
        emit TaskUpdated(taskId);
    }

    function updateTask(uint256 taskId, bytes calldata description, TaskState state) external onlyOwner {
        tasks[taskId].description = description;
        tasks[taskId].state = state;
        emit TaskUpdated(taskId);
    }

    function deleteTask(uint256 taskId) external onlyOwner {
        uint256 lastId = tasks.length - 1;
        if (lastId != 0 && taskId != lastId) {
            tasks[taskId] = tasks[lastId];
            emit TaskIdMoved(lastId, taskId);
        }
        tasks.pop();
        emit TaskDeleted(taskId);
        payable(msg.sender).transfer(taskCost);
    }
}
