"use client";

import { useState } from "react";
import { ethers } from "ethers";
import abi from "./abi.json";
import TasksTable from "../components/TasksTable";


export default function Home() {

    const [errorMessage, setErrorMessage] = useState("");
    const [metamaskAccount, setMetamaskAccount] = useState("");
    const [contractAddress, setContractAddress] = useState("");
    const [contract, setContract] = useState(null as null | ethers.Contract);
  
    function connectToMetamask() {
        if(window.ethereum) {
            window.ethereum.request({ method: 'eth_requestAccounts' })
            .then((result: Array<string>) => {
                setMetamaskAccount(result[0]);
            })
        } else {
            setErrorMessage("Metamask not found");  
        }
    }
  
    async function connectToContract() {
        if(!contractAddress || contractAddress === "") {
            setErrorMessage("Contract address is empty");
            return;
        }
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const contract = new ethers.Contract(contractAddress, abi, signer);
        setContract(contract);
    }
  
    function disconnect() {
        setMetamaskAccount("");
        setContractAddress("")
        setContract(null);
    }

  return (
    <>
      <header className="flex flex-row justify-between items-center py-6 px-8 ">
        <h1 className="text-4xl font-bold">Todo List</h1>
        {
            metamaskAccount ?
            <div className="flex flex-row space-x-4 justify-center items-center">
                <p>{metamaskAccount}</p>
                <button className="bg-blue-500 text-white px-4 py-2 rounded-md" onClick={disconnect}>Se déconnecter</button>
            </div>
            :
            <button className="bg-blue-500 text-white px-4 py-2 rounded-md" onClick={connectToMetamask}>Se connecter à Metamask</button>
        }
      </header>
      <main className="flex flex-col space-y-4 max-w-2xl mx-auto">
        <p className="text-red-500 text-center">{errorMessage}</p>
        {
          metamaskAccount && !contract &&
          <div className="flex flex-row space-x-4 justify-center items-center">
            <input className="text-black border border-slate-200 px-4 py-2 rounded-md" type="text" onChange={(e) => setContractAddress(e.target.value)} placeholder="Adresse du contrat" />
            <button className="bg-blue-500 text-white px-4 py-2 rounded-md" onClick={connectToContract}>Se connecter au contrat</button>
          </div>
        }
        {contract && <TasksTable contract={contract} />}
      </main>
    </>
  );
}
