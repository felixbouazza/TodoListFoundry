// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

enum TaskState {
    Todo,
    Doing,
    Done
}

struct Task {
    bytes description;
    TaskState state;
    uint createdAt;
}

contract TodoList {

    address public immutable owner;
    uint public constant taskCost = 0.01 ether;
    Task[] private tasks;

    event TaskCreated(uint indexed taskId);
    event TaskUpdated(uint indexed taskId);
    event TaskDeleted(uint indexed taskId);
    event TaskIdMoved(uint fromId, uint toId);

    error Unauthorized();
    error IncorrectEther();

    modifier onlyOwner() {
        if(msg.sender != owner)
            revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function getTask(uint taskId) external view onlyOwner() returns (bytes memory description, TaskState state) {
        return (tasks[taskId].description, tasks[taskId].state);
    }

    function getTasks() external view onlyOwner() returns (uint[] memory ids) {
        ids = new uint[](tasks.length);
        for (uint i = 0; i < tasks.length; i++) {
            ids[i] = i;
        }
        return ids;
    }

    function createTask(bytes calldata description) external payable onlyOwner() {
        if (msg.value != taskCost)
            revert IncorrectEther();

        tasks.push(
            Task(description, TaskState.Todo, block.timestamp)
        );
        emit TaskCreated(tasks.length - 1);
    }

    function updateTaskDescription(uint taskId, bytes calldata description) external onlyOwner() {
        tasks[taskId].description = description;
        emit TaskUpdated(taskId);
    }

    function updateTaskState(uint taskId, TaskState state) external onlyOwner() {
        tasks[taskId].state = state;
        emit TaskUpdated(taskId);
    }

    function updateTask(uint taskId, bytes calldata description, TaskState state) external onlyOwner() {
        tasks[taskId].description = description;
        tasks[taskId].state = state;
        emit TaskUpdated(taskId);
    }

    function deleteTask(uint taskId) external onlyOwner() {
        uint lastId = tasks.length - 1;
        if (lastId != 0 && taskId != lastId) {
            tasks[taskId] = tasks[lastId];
            emit TaskIdMoved(lastId, taskId);
        }
        tasks.pop();
        emit TaskDeleted(taskId);
        payable(msg.sender).transfer(taskCost);
    }

}