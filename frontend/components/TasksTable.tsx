import { ethers } from "ethers";
import { useState, useEffect } from "react";
import { TaskType } from "../app/type";
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';

class Task {
    id: number;
    description: string;
    status: number;

    constructor(id: number, description: ethers.BytesLike, status: number) {
        this.id = id;
        this.description = ethers.toUtf8String(description);
        this.status = status;
    }
}

export default function TasksTable({ contract }: { contract: ethers.Contract }) {

    const [initialLoading, setInitialLoading] = useState(false);
    const [eventLoading, setEventLoading] = useState(false);
    const [tasks, setTasks] = useState([] as Array<Task>);
    const [newTaskDescription, setNewTaskDescription] = useState("");
    const [openModal, setOpenModal] = useState(false);
    const [updatedTask, setUpdatedTask] = useState(null as null | Task);

    contract.on("TaskCreated", (taskId: number) => {
        getTasks();
        setEventLoading(false)
    });

    contract.on("TaskDeleted", (taskId: number) => {
        getTasks();
        setEventLoading(false)
    });

    contract.on("TaskUpdated", (taskId: number) => {
        getTasks();
        setEventLoading(false)
    });

    const getTasks = async() => {
        const ids = await contract.getTasks();
        const tasks: Array<Task> = await Promise.all(ids.map(async (id: number) => {
            const task = await contract.getTask(id);
            const newTask = new Task(id, task.description, task.state);
            return newTask;
        }));
        setTasks(tasks);
    }

    const deleteTask = async(id: number) => {
        await contract.deleteTask(id);
        setEventLoading(true);
    }

    const convertTaskStatus = (status: number) => {
        switch(Number(status)) {
            case 0:
                return "À faire";
            case 1:
                return "En cours";
            case 2:
                return "Fait";
            default:
                return "Unknown";
        }
    }

    const createTask = async() => {
        const taskDescriptionBytes = ethers.toUtf8Bytes(newTaskDescription);
        await contract.createTask(taskDescriptionBytes, {value: ethers.parseEther("0.01")});
        setEventLoading(true);
    }

    const updateTask = async (id: number, description: string, status: number) => { 
        const taskDescriptionBytes = ethers.toUtf8Bytes(description);
        await contract.updateTask(id, taskDescriptionBytes, status);
        setEventLoading(true);
    }

    const openModalForTask = (task: Task) => {
        setOpenModal(true);
        setUpdatedTask(task);
    }

    const closeModal = () => {
        setOpenModal(false);
    }

    useEffect(() => {
        setInitialLoading(true);
        getTasks().finally(() => {
            setInitialLoading(false);
        });
    }, []);

    return (
        <>
        {eventLoading && <p className="text-center text-blue-500">Loading for event...</p>}
        {initialLoading ? <p>Loading...</p> : 
        <div className="flex flex-col space-y-4">
            <div className="flex flex-row space-x-4 justify-center items-center">
                <input disabled={eventLoading} className="text-black border border-slate-200 px-4 py-2 rounded-md" type="text" onChange={(e) => setNewTaskDescription(e.target.value)} placeholder="Nouvelle tâche" />
                {newTaskDescription.trim() && <button disabled={eventLoading} className="bg-blue-500 text-white px-4 py-2 rounded-md" onClick={createTask}>Créer</button>}
            </div>
            <table className="table-auto border-collapse border border-slate-200 w-full">
                <thead>
                    <tr>
                        <th className="border border-slate-200 px-4 py-2">Description</th>
                        <th className="border border-slate-200 px-4 py-2">State</th>
                        <th className="border border-slate-200 px-4 py-2">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {tasks.map((task: Task, index: number) => {
                        return (
                            <tr key={index}>
                                <td className="border border-slate-200 px-4 py-2">{task.description}</td>
                                <td className="border border-slate-200 px-4 py-2">{convertTaskStatus(task.status)}</td>
                                <td className="border border-slate-200 px-4 py-2 flex flex-row space-x-4">
                                    <button className="bg-green-500 text-white px-4 py-2 rounded-md" disabled={eventLoading} onClick={() => openModalForTask(task)}>Modifier</button>
                                    <button className="bg-red-500 text-white px-4 py-2 rounded-md" disabled={eventLoading} onClick={() => deleteTask(task.id)}>Supprimer</button>
                                </td>
                            </tr>
                        );
                    })}
                </tbody>
                <tfoot>
                    <tr>
                        <th><button className="bg-yellow-500 text-white px-4 py-2 rounded-md">Rafraichir les données</button></th>
                    </tr>
                </tfoot>
            </table>
            <Dialog
                open={openModal}
                onClose={closeModal}
                slotProps={{
                paper: {
                    component: 'form',
                    onSubmit: async (event: React.FormEvent<HTMLFormElement>) => { 
                        event.preventDefault();
                        if (!updatedTask) {
                            return;
                        }
                        const formData = new FormData(event.currentTarget);
                        const formJson = Object.fromEntries((formData as any).entries());
                        await updateTask(updatedTask.id, formJson.description, formJson.status);
                        closeModal();
                    },
                },
                }}
            >
                <DialogTitle>Mettre à jour la tâche</DialogTitle>
                <DialogContent>
                    <TextField
                        autoFocus
                        required
                        margin="dense"
                        label="Description"
                        type="text"
                        fullWidth
                        variant="standard"
                        name="description"
                        placeholder={updatedTask?.description}
                    />
                    <InputLabel id="demo-simple-select-label">Statut</InputLabel>
                    <Select
                        labelId="demo-simple-select-label"
                        id="demo-simple-select"
                        name="status"
                        defaultValue={Number(updatedTask?.status)}
                        label="Statut"
                    >
                        <MenuItem value={0}>À faire</MenuItem>
                        <MenuItem value={1}>En cours</MenuItem>
                        <MenuItem value={2}>Fait</MenuItem>
                    </Select>
                </DialogContent>
                <DialogActions>
                    <Button onClick={closeModal}>Annuler</Button>
                    <Button type="submit">Modifier</Button>
                </DialogActions>
            </Dialog>
        </div>
        }
        </>
    )
}
