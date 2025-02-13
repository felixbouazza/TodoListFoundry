import {ethers} from "ethers";

enum TaskStatus {
    Todo,
    Doing,
    Done,
}

interface TaskType {
    id: number;
    description: ethers.BytesLike;
    status: TaskStatus;
}


export type { TaskType, TaskStatus };