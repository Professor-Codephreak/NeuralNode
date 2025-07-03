let provider;
let signer;
let address;

// Replace with actual deployed contract addresses
const V1_ADDRESS = '0xV1...';
const V2_ADDRESS = '0xV2...';
const V3_ADDRESS = '0xV3...';

async function connectWallet() {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    address = await signer.getAddress();
    log("Wallet connected: " + address, "outputV1");
}

function log(message, target) {
    const el = document.getElementById(target);
    el.innerText += message + "\n";
}

// V1 Interaction
async function mintRoomV1() {
    const contract = new ethers.Contract(V1_ADDRESS, abi1, signer);
    const tx = await contract.mintRoom("ipfs://metadata", "Theme", "Origin", [address], [0]);
    await tx.wait();
    log("Room minted (V1)", "outputV1");
}

// V2 Interaction
async function transferOwnershipV2() {
    const contract = new ethers.Contract(V2_ADDRESS, abi2, signer);
    const tx = await contract.transferRoomOwnership(1, "0xNewOwner...");
    await tx.wait();
    log("Ownership transferred (V2)", "outputV2");
}

async function inviteToRoomV2() {
    const contract = new ethers.Contract(V2_ADDRESS, abi2, signer);
    const tx = await contract.inviteParticipant(1, "0xInvitee...", 1);
    await tx.wait();
    log("Participant invited (V2)", "outputV2");
}

// V3 Interaction
async function mintVaultRoomV3() {
    const contract = new ethers.Contract(V3_ADDRESS, abi3, signer);
    const tx = await contract.mintRoom(
        "ipfs://vaultMeta", "Vault", "DropEvent", [address],
        [0], true, true, true, 8, Date.now() + 3600 * 1000,
        "ipfs://encryptedCID", true
    );
    await tx.wait();
    log("Vault room minted (V3)", "outputV3");
}

async function checkAccessV3() {
    const contract = new ethers.Contract(V3_ADDRESS, abi3, signer);
    const result = await contract.canAccessRoom(1, address);
    log("Access: " + result, "outputV3");
}
