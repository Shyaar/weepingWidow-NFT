// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/utils/Strings.sol";

import {IERC721, IERC721Receiver} from "./interfaces/ierc721.sol";
import {Events} from "./lib/events.sol";

contract BLT_NFT is IERC721, IERC721Receiver {
    string private _baseTokenURI =
        "ipfs://QmYK1ohUjyhBAqBs4FcpZ6z2Hd95ihU7E91r2qJM42tagf/";

    mapping(address => uint256) private _balances;
    mapping(uint256 => address) public _ownerOfNft;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint => uint) public totalSupplyOfTokens;

    mapping(uint256 => string) private _tokenURIs;

    modifier onlyAdmin() {
        require(msg.sender == admin, "youre not an admin");
        _;
    }

    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function balanceOf(address owner) external view returns (uint256 balance_) {
        balance_ = _balances[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address owner_) {
        owner_ = _ownerOfNft[tokenId];
    }

    // Transfers
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external {
        this.transferFrom(from, to, tokenId);

        if (to.code.length > 0) {
            require(
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                ) == IERC721Receiver.onERC721Received.selector,
                "Receiver not implemented"
            );
        }

        emit Events.Transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        this.safeTransferFrom(from, to, tokenId, "");
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        require(to != address(0), "Invalid address to transfer to!");
        require(
            _ownerOfNft[tokenId] == from,
            "This is not the owner of the NFT"
        );
        require(
            from == msg.sender ||
                _tokenApprovals[tokenId] == from ||
                _operatorApprovals[msg.sender][from],
            "You dont have the authority to transfer this NFT"
        );

        delete _tokenApprovals[tokenId];

        _balances[from] -= 1;
        _balances[to] += 1;

        _ownerOfNft[tokenId] = to;

        emit Events.Transfer(from, to, tokenId);
    }

    // Approval
    function approve(address to, uint256 tokenId) external {
        require(to != address(0), "Invalid address to grant approval to!");

        _tokenApprovals[tokenId] = to;

        emit Events.Approval(msg.sender, to, tokenId);
    }

    function getApproved(
        uint256 tokenId
    ) external view returns (address operator) {
        operator = _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool _approved) external {
        require(
            operator != address(0),
            "Invalid address to grant approval to!"
        );

        _operatorApprovals[msg.sender][operator] = _approved;

        emit Events.ApprovalForAll(msg.sender, operator, _approved);
    }
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        emit Events.Received(operator, from, tokenId, data);

        return IERC721Receiver.onERC721Received.selector;
    }

    function _baseURI() internal view returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_ownerOfNft[tokenId] != address(0), "Token does not exist");
        return
            string(
                abi.encodePacked(_baseURI(), Strings.toString(tokenId), ".json")
            );
    }

    function mint(uint256 tokenId) internal {
        _balances[msg.sender] += 1;
        _ownerOfNft[tokenId] = msg.sender;
    }
}
