import {ethers} from "ethers";

enum TaskStatus {
    Todo,
    Doing,
    Done,
}

interface Task {
    id: number;
    description: ethers.BytesLike;
    status: TaskStatus;
}

enum TaskActionKind {
    ADD = 'ADD',
    UPDATE = 'UPDATE',
    DELETE = 'DELETE',
    RESET = 'RESET'
}

interface TaskAction {
    type: TaskActionKind;
    payload: Task & Array<Task>;
}

export type { Task, TaskStatus, TaskAction };
export { TaskActionKind };