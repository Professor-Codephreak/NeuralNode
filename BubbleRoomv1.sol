// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ITW33TPassport {
    function hasPassport(address user) external view returns (bool);
    function getIdentity(address user) external view returns (
        string memory ens,
        string memory pgpKey,
        string memory litKey
    );
}

contract BubbleRoomV1 is ERC721URIStorage, Ownable {
    uint256 public nextRoomId = 1;
    address public passportContract;

    enum Role { NONE, MEMBER, AGENT, MODERATOR }

    struct Room {
        string theme;
        string originEvent;
        uint256 timestamp;
        bool isActive;
        address owner;
        mapping(address => Role) participantRoles;
        address[] participants;
    }

    mapping(uint256 => Room) private rooms;

    event RoomCreated(uint256 indexed roomId, string theme, address indexed creator);
    event ParticipantAdded(uint256 indexed roomId, address indexed user, Role role);

    modifier onlyRoomOwner(uint256 roomId) {
        require(ownerOf(roomId) == msg.sender, "Not room owner");
        _;
    }

    constructor(address _passportContract) ERC721("BubbleRoom", "BROOM") {
        passportContract = _passportContract;
    }

    function mintRoom(
        string memory metadataURI,
        string memory theme,
        string memory originEvent,
        address[] memory initialParticipants,
        Role[] memory roles
    ) external returns (uint256) {
        require(initialParticipants.length == roles.length, "Participant/role mismatch");

        uint256 roomId = nextRoomId++;
        _safeMint(msg.sender, roomId);
        _setTokenURI(roomId, metadataURI);

        Room storage r = rooms[roomId];
        r.theme = theme;
        r.originEvent = originEvent;
        r.timestamp = block.timestamp;
        r.isActive = true;
        r.owner = msg.sender;

        for (uint256 i = 0; i < initialParticipants.length; i++) {
            r.participantRoles[initialParticipants[i]] = roles[i];
            r.participants.push(initialParticipants[i]);
            emit ParticipantAdded(roomId, initialParticipants[i], roles[i]);
        }

        emit RoomCreated(roomId, theme, msg.sender);
        return roomId;
    }

    function getRoomParticipants(uint256 roomId) external view returns (address[] memory) {
        return rooms[roomId].participants;
    }

    function getParticipantRole(uint256 roomId, address user) external view returns (Role) {
        return rooms[roomId].participantRoles[user];
    }
}
