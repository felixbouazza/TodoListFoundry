import { createContext, useContext, useReducer } from 'react';
import { Task, TaskAction, TaskActionKind } from '../app/type';

const TasksContext = createContext([] as Array<Task>);

const TasksDispatchContext = createContext(null as null | React.Dispatch<TaskAction>);
 
const initialTasks: Array<Task> = []
  

function tasksReducer(tasks: Array<Task>, action: TaskAction) {
    switch (action.type) {
        case TaskActionKind.ADD: {
            return [...tasks, action.payload];
        }
        case TaskActionKind.UPDATE: {
            return tasks.map(t => {
                if (t.id === action.payload.id) {
                    return action.payload;
                } else {
                    return t;
                }
            });
        }
        case TaskActionKind.DELETE: {
            return tasks.filter(t => t.id !== action.payload.id);
        }
        default: {
            throw Error('Unknown action: ' + action.type);
        }
    }
}

export function TasksProvider({
    children,
  }: Readonly<{
    children: React.ReactNode;
  }>) {

    const [tasks, dispatch] = useReducer(
        tasksReducer,
        initialTasks
    );

    return (
        <TasksContext.Provider value={tasks}>
            <TasksDispatchContext.Provider value={dispatch}>
                {children}
            </TasksDispatchContext.Provider>
        </TasksContext.Provider>
    );
}

export function useTasks() {
    return useContext(TasksContext);
}

export function useTasksDispatch() {
    return useContext(TasksDispatchContext);
}