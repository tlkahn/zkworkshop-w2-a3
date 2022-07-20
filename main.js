const snarkjs = require('snarkjs')
const fs = require('fs')

const wc = require('./circuit_js/witness_calculator.js')
const wasm = './circuit_js/circuit.wasm'
const zkey = './circuit_final.zkey'
const INPUTS_FILE = './input.json'
const WITNESS_FILE = './witness.wtns'

const generateWitness = async (inputs) => {
    const buffer = fs.readFileSync(wasm)
    const witnessCalculator = await wc(buffer)
    const buff = await witnessCalculator.calculateWTNSBin(inputs, 0)
    fs.writeFileSync(WITNESS_FILE, buff)
}

const main = async () => {
    const inputSignals = JSON.parse(fs.readFileSync(INPUTS_FILE, 'utf8'))
    await generateWitness(inputSignals)
    const { proof, publicSignals } = await snarkjs.plonk.prove(zkey, WITNESS_FILE)
    console.log("proof:\n", proof)
    const vkey = JSON.parse(fs.readFileSync('./verification_key.json', 'utf8'))
    const res = await snarkjs.plonk.verify(vkey, publicSignals, proof)
    if (res === true) {
        console.log("Verification OK")
    } else {
        console.log("Invalid proof")
    }
}

main().then(() => {
    process.exit(0)
})