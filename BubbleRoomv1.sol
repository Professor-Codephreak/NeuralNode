
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BubbleRoomV3 is ERC721URIStorage, Ownable {
    uint256 public nextRoomId = 1;

    enum Role { NONE, MEMBER, AGENT, MODERATOR }
    enum RoomType { TEMPORARY, LIVING, EPHEMERAL, ARCHIVAL, INCUBATOR, SIGNAL, STORAGE, TIMELOCKED, VAULT }

    struct Room {
        string theme;
        string originEvent;
        uint256 timestamp;
        uint256 unlockTime;
        string storageCID;
        bool isEncryptedStorage;
        bool isPrivate;
        bool isStable;
        bool isSoulbound;
        bool isActive;
        RoomType roomType;
        address owner;
        mapping(address => Role) participantRoles;
        address[] participants;
    }

    mapping(uint256 => Room) private rooms;

    event RoomCreated(uint256 indexed roomId, string theme, RoomType roomType, address creator);
    event ParticipantInvited(uint256 indexed roomId, address invitee, Role role);
    event RoomUnlocked(uint256 indexed roomId);

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
        bool isSoulbound,
        RoomType roomType,
        uint256 unlockTime,
        string memory storageCID,
        bool isEncryptedStorage
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
        r.roomType = roomType;
        r.owner = msg.sender;
        r.unlockTime = unlockTime;
        r.storageCID = storageCID;
        r.isEncryptedStorage = isEncryptedStorage;

        for (uint256 i = 0; i < initialParticipants.length; i++) {
            r.participantRoles[initialParticipants[i]] = roles[i];
            r.participants.push(initialParticipants[i]);
            emit ParticipantInvited(roomId, initialParticipants[i], roles[i]);
        }

        emit RoomCreated(roomId, theme, roomType, msg.sender);
        return roomId;
    }

    function canAccessRoom(uint256 roomId, address user) public view returns (bool) {
        Room storage r = rooms[roomId];
        if (!r.isActive) return false;
        if (r.roomType == RoomType.TIMELOCKED && block.timestamp < r.unlockTime) return false;
        if (r.isPrivate && r.participantRoles[user] == Role.NONE) return false;
        return true;
    }

    function getRoomParticipants(uint256 roomId) external view returns (address[] memory) {
        return rooms[roomId].participants;
    }

    function getParticipantRole(uint256 roomId, address user) external view returns (Role) {
        return rooms[roomId].participantRoles[user];
    }
}
