"use strict";

const Web3 = require('web3');
const Contract = require('web3-eth-contract');
const Tx = require('ethereumjs-tx');
const UTIL = require('./utils');
const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

//define your address which receive
// const userAddress = '0x9A8cC4fCfF2F473cc1B70c5959097F16e15A9762';
// const userAddress = '0x45205277883f8a31d78f9f681e4e23f604dad152';
const userAddress = '0xF54b3294616d39749732Ac74F234F46C9ABf29C4';
// const userAddress = '0x041E7912541745A67F8c652a6bEe3CBAd131481d';



let web3 = new Web3();

web3.setProvider(new Web3.providers.HttpProvider('http://192.168.1.208:22002'));

const zrxContractAddress = '0x5a1830Ebe15f422C1A9dFC04e2C7ad496cecA12a';
const hatContractAddress = '0x0e4355d3cB1796Bcf695c3172c43a151FBFDE367';
const ownAddress = '0x7f20FDc32659D55CF39522598d169D0586DE02Fd';

const tokenAddress = [zrxContractAddress, hatContractAddress];
const tokenABI = [UTIL.ABI.zrxAbi, UTIL.ABI.hatAbi];

const mintZrx = async () => {
    const contract = new web3.eth.Contract(UTIL.ABI.zrxAbi, zrxContractAddress);
    let count = await web3.eth.getTransactionCount(ownAddress);
    console.log(count);
    let txOb = {
        nonce:    web3.utils.toHex(count),
        gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
        gasPrice: web3.utils.toHex(1000000000),
        from: ownAddress,
        to: zrxContractAddress,
        data: contract.methods.transfer(userAddress, '10000000000000000000000000').encodeABI()
    }
    const rawTx = await web3.eth.signTransaction(txOb, ownAddress);
    const raw = rawTx.raw;
    await web3.eth.sendSignedTransaction(raw).once('confirmation', function(confirmationNumber, receipt) {
        console.log("Success");
    })
}
const getBalance = async (abi, addrContract, addr) => {
    const contract = new web3.eth.Contract(abi, addrContract);
    const balance = await contract.methods.balanceOf(addr).call()
    return balance;
}

const mintHat = async () => {
    const contract = new web3.eth.Contract(UTIL.ABI.hatAbi, hatContractAddress);
    let count = await web3.eth.getTransactionCount(ownAddress);
    let txOb = {
        nonce:    web3.utils.toHex(count),
        gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
        gasPrice: web3.utils.toHex(1000000000),
        from: ownAddress,
        to: hatContractAddress,
        data: contract.methods.transfer(userAddress, '10000000000000000000000000').encodeABI()
    }
    const rawTx = await web3.eth.signTransaction(txOb, ownAddress);
    const raw = rawTx.raw;
    await web3.eth.sendSignedTransaction(raw).once('confirmation', function(confirmationNumber, receipt) {
        console.log("Success");
    })
}

mintZrx().then(async () => {
    const balance = await getBalance(UTIL.ABI.zrxAbi, zrxContractAddress, userAddress);
    console.log(balance);
})

// mintHat().then(async () => {
//     const balance = await getBalance(UTIL.ABI.hatAbi, hatContractAddress, userAddress);
//     console.log(balance);
// })

