let provider, signer, address;

const V1_ADDRESS = '0xYourBubbleRoomV1';
const V2_ADDRESS = '0xYourBubbleRoomV2';
const V3_ADDRESS = '0xYourBubbleRoomV3';

async function connectWallet() {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    address = await signer.getAddress();
    log(`Connected wallet: ${address}`, "walletOutput");
}

function log(msg, target) {
    document.getElementById(target).innerText += msg + "\n";
}

// ------------------ V1 -------------------

async function mintRoomV1() {
    const contract = new ethers.Contract(V1_ADDRESS, abi1, signer);
    try {
        const tx = await contract.mintRoom(
            "ipfs://exampleMetaV1",
            "Terminal Lounge",
            "tw33t-0001",
            [address],
            [0] // Role.MEMBER
        );
        await tx.wait();
        log("Room minted (V1)", "outputV1");
    } catch (err) {
        log("Error: " + err.message, "outputV1");
    }
}

async function getParticipantsV1() {
    const contract = new ethers.Contract(V1_ADDRESS, abi1, signer);
    try {
        const result = await contract.getRoomParticipants(1);
        log("Participants (V1): " + result.join(", "), "outputV1");
    } catch (err) {
        log("Error: " + err.message, "outputV1");
    }
}

// ------------------ V2 -------------------

async function mintRoomV2() {
    const contract = new ethers.Contract(V2_ADDRESS, abi2, signer);
    try {
        const tx = await contract.mintRoom(
            "ipfs://exampleMetaV2",
            "Signal Hive",
            "tw33t-0420",
            [address],
            [1], // Role.AGENT
            true,  // isPrivate
            false, // isStable
            false  // isSoulbound
        );
        await tx.wait();
        log("Room minted (V2)", "outputV2");
    } catch (err) {
        log("Error: " + err.message, "outputV2");
    }
}

async function inviteToRoomV2() {
    const contract = new ethers.Contract(V2_ADDRESS, abi2, signer);
    const invitee = prompt("Enter wallet address to invite:");
    try {
        const tx = await contract.inviteParticipant(1, invitee, 0); // Role.MEMBER
        await tx.wait();
        log(`Invited ${invitee} to room (V2)`, "outputV2");
    } catch (err) {
        log("Error: " + err.message, "outputV2");
    }
}

async function transferOwnershipV2() {
    const contract = new ethers.Contract(V2_ADDRESS, abi2, signer);
    const newOwner = prompt("Enter new owner address:");
    try {
        const tx = await contract.transferRoomOwnership(1, newOwner);
        await tx.wait();
        log(`Ownership transferred to ${newOwner} (V2)`, "outputV2");
    } catch (err) {
        log("Error: " + err.message, "outputV2");
    }
}

async function getParticipantsV2() {
    const contract = new ethers.Contract(V2_ADDRESS, abi2, signer);
    try {
        const result = await contract.getRoomParticipants(1);
        log("Participants (V2): " + result.join(", "), "outputV2");
    } catch (err) {
        log("Error: " + err.message, "outputV2");
    }
}

// ------------------ V3 -------------------

async function mintRoomV3() {
    const contract = new ethers.Contract(V3_ADDRESS, abi3, signer);
    try {
        const tx = await contract.mintRoom(
            "ipfs://metaV3",
            "Living Room – Broadcast Core",
            "signal-994",
            [address],
            [2],     // Role.MODERATOR
            true,    // isPrivate
            true,    // isStable
            false,   // isSoulbound
            1,       // RoomType.LIVING
            0,       // unlockTime
            "",      // storageCID
            false    // isEncryptedStorage
        );
        await tx.wait();
        log("Room minted (V3)", "outputV3");
    } catch (err) {
        log("Error: " + err.message, "outputV3");
    }
}

async function mintVaultRoomV3() {
    const contract = new ethers.Contract(V3_ADDRESS, abi3, signer);
    try {
        const tx = await contract.mintRoom(
            "ipfs://vaultMetaV3",
            "Crypt0Vault",
            "drop-9001",
            [address],
            [2],     // Role.MODERATOR
            true,    // isPrivate
            true,    // isStable
            true,    // isSoulbound
            8,       // RoomType.VAULT
            Math.floor(Date.now() / 1000) + 60 * 60, // unlockTime in 1 hr
            "ipfs://QmEncryptedBlob",
            true     // isEncryptedStorage
        );
        await tx.wait();
        log("Vault Room minted (V3)", "outputV3");
    } catch (err) {
        log("Error: " + err.message, "outputV3");
    }
}

async function checkAccessV3() {
    const contract = new ethers.Contract(V3_ADDRESS, abi3, signer);
    try {
        const result = await contract.canAccessRoom(1, address);
        log(`Access to Room 1: ${result}`, "outputV3");
    } catch (err) {
        log("Error: " + err.message, "outputV3");
    }
}

async function getParticipantsV3() {
    const contract = new ethers.Contract(V3_ADDRESS, abi3, signer);
    try {
        const result = await contract.getRoomParticipants(1);
        log("Participants (V3): " + result.join(", "), "outputV3");
    } catch (err) {
        log("Error: " + err.message, "outputV3");
    }
}
