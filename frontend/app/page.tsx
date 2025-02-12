"use client";

import TasksTable from "@/components/TasksTable";
import { TasksProvider } from '@/components/TasksContext';
import MetamaskManager from "@/components/MetamaskManager";

export default function Home() {

  return (
    <>
      <header className="flex flex-row justify-between items-center py-6 px-8 ">
        <h1 className="text-4xl font-bold">Todo List</h1>
        <MetamaskManager />
      </header>
      <main>
        <TasksProvider>
            <TasksTable />
        </TasksProvider>
      </main>
    </>
  );
}
