// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ITW33TPassport {
    function getIdentity(address user) external view returns (
        string memory ens,
        string memory pgpKey,
        string memory litKey
    );
}

contract BubbleRoomV2 is ERC721URIStorage, Ownable {
    uint256 public nextRoomId = 1;

    enum Role { NONE, MEMBER, AGENT, MODERATOR }

    struct Room {
        string theme;
        string originEvent;
        uint256 timestamp;
        bool isPrivate;
        bool isStable;
        bool isSoulbound;
        bool isActive;
        address owner;
        mapping(address => Role) participantRoles;
        address[] participants;
    }

    mapping(uint256 => Room) private rooms;

    event RoomCreated(uint256 indexed roomId, string theme, address creator, bool isPrivate, bool isStable);
    event ParticipantInvited(uint256 indexed roomId, address invitee, Role role);
    event RoomDeactivated(uint256 indexed roomId);
    event RoomOwnershipTransferred(uint256 indexed roomId, address from, address to);

    modifier onlyRoomOwner(uint256 roomId) {
        require(ownerOf(roomId) == msg.sender, "Not room owner");
        _;
    }

    constructor() ERC721("BubbleRoom", "BROOM") {}

    function mintRoom(
        string memory metadataURI,
        string memory theme,
        string memory originEvent,
        address[] memory initialParticipants,
        Role[] memory roles,
        bool isPrivate,
        bool isStable,
        bool isSoulbound
    ) external returns (uint256) {
        require(initialParticipants.length == roles.length, "Participant/role mismatch");

        uint256 roomId = nextRoomId++;
        _safeMint(msg.sender, roomId);
        _setTokenURI(roomId, metadataURI);

        Room storage r = rooms[roomId];
        r.theme = theme;
        r.originEvent = originEvent;
        r.timestamp = block.timestamp;
        r.isPrivate = isPrivate;
        r.isStable = isStable;
        r.isSoulbound = isSoulbound;
        r.isActive = true;
        r.owner = msg.sender;

        for (uint256 i = 0; i < initialParticipants.length; i++) {
            r.participantRoles[initialParticipants[i]] = roles[i];
            r.participants.push(initialParticipants[i]);
            emit ParticipantInvited(roomId, initialParticipants[i], roles[i]);
        }

        emit RoomCreated(roomId, theme, msg.sender, isPrivate, isStable);
        return roomId;
    }

    function inviteParticipant(uint256 roomId, address invitee, Role role) external onlyRoomOwner(roomId) {
        Room storage r = rooms[roomId];
        require(r.isActive, "Inactive room");
        require(role != Role.NONE, "Invalid role");

        r.participantRoles[invitee] = role;
        r.participants.push(invitee);
        emit ParticipantInvited(roomId, invitee, role);
    }

    function transferRoomOwnership(uint256 roomId, address newOwner) external onlyRoomOwner(roomId) {
        require(!rooms[roomId].isSoulbound, "Soulbound");
        _transfer(msg.sender, newOwner, roomId);
        rooms[roomId].owner = newOwner;
        emit RoomOwnershipTransferred(roomId, msg.sender, newOwner);
    }

    function getRoomParticipants(uint256 roomId) external view returns (address[] memory) {
        return rooms[roomId].participants;
    }

    function getParticipantRole(uint256 roomId, address user) external view returns (Role) {
        return rooms[roomId].participantRoles[user];
    }
}
