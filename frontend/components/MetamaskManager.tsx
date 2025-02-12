"use client";

import { useState } from "react";
import { ethers } from "ethers";
import abi from "./abi.json";

export default function MetamaskManager() { 
    
    const [errorMessage, setErrorMessage] = useState(null as null | string);
    const [metamaskAccount, setMetamaskAccount] = useState(null as null | string);
    const [contract, setContract] = useState(null as null | ethers.Contract);
  
    function connectToMetamask() {
        if(window.ethereum) {
            window.ethereum.request({ method: 'eth_requestAccounts' })
            .then((result: Array<string>) => {
                setMetamaskAccount(result[0]);
                connectToContract();
            })
        } else {
            setErrorMessage("Metamask not found");  
        }
    }
  
    async function connectToContract() {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const contract = new ethers.Contract(contractAddress, abi, signer);
        setContract(contract);
    }
  
    function disconnect() {
        setMetamaskAccount(null);
        setContract(null);
    }
    
    return (
        <>
            <p className="text-red-500">{errorMessage}</p>
            {
                metamaskAccount ?
                <div className="flex flex-row space-x-4 justify-center items-center">
                    <p>{metamaskAccount}</p>
                    <button className="bg-blue-500 text-white px-4 py-2 rounded-md" onClick={disconnect}>Disconnect</button>
                </div>
                :
                <button className="bg-blue-500 text-white px-4 py-2 rounded-md" onClick={connectToMetamask}>Connect to metamask</button>
            }
        </>
    )
}