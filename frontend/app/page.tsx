import MetamaskManager from "@/components/MetamaskManager";

export default function Home() {
  return (
    <>
      <div className="flex flex-row justify-between items-center py-6 px-8 ">
        <h1 className="text-4xl font-bold">Todo List</h1>
        <MetamaskManager />
      </div>
    </>
  );
}
