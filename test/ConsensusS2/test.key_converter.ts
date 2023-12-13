import { ethers } from "hardhat";
import { Wallet } from "ethers";

async function key_to_signer(priv: string) {
    // Converts private key to a signer
    const provider = ethers.provider;
    console.log("DEBUG ------------------ ")
    console.log(provider)
    const signer_wallet = new Wallet(priv);
    const signer = signer_wallet.connect(provider);
    return signer;
}

export=key_to_signer;
