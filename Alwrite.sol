// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Alwrite is ERC1155, Ownable {
    
    mapping(uint256 => Post) public posts;
    mapping(uint256 => string) private uris;
    mapping(address => uint256) public pendingWallets;
    uint256 public price;
    
    struct Post {
        uint256 minted;
        address[] coauthors;
        address owner;
    }
    
    constructor() ERC1155("") {
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }
    
    function uri(uint256 tokenId) override public view returns (string memory) {
        return(uris[tokenId]);
    }
    
    function setTokenUri(uint256 tokenId, string memory _uri) private {
        uris[tokenId] = _uri;
    }
    
    function addAuthor(address _coauthor, uint256 _token) external {
        require(_coauthor != address(0), "Invalid coauthor address");
        require(posts[_token].owner == msg.sender, "You are not the owner of this blog");
        posts[_token].coauthors.push(_coauthor);
    }
    
    function mint(uint256 _tokenId, string memory _tokenURI, address _owner) public payable {
        require(_owner != address(0), "Invalid owner address");
        Post storage newPost = posts[_tokenId];
        if (newPost.minted > 0) {
            require(keccak256(abi.encodePacked(uri(_tokenId))) == keccak256(abi.encodePacked(_tokenURI)), "Wrong uri");
            require(newPost.owner == _owner, "Wrong owner");
        }
        require(newPost.minted < 100, "Sold out");
        require(msg.value >= price, "Incorrect payment amount");
        _mint(msg.sender, _tokenId, 1, "");
        setTokenUri(_tokenId, _tokenURI);
        if (newPost.minted == 0) {
            newPost.owner = _owner;
            newPost.minted++;
        } else {
            newPost.minted++;
        }
        pendingWallets[newPost.owner] += price;
    }
    
    function getAuthors(uint256 _token) view public returns(address[] memory) {
        return posts[_token].coauthors;
    }
    
    function withdraw() public {
        address payable receiver = payable(msg.sender);
        
        uint amount = pendingWallets[receiver];
        require(amount > 0, "No pending withdrawals");
        
        pendingWallets[receiver] = 0;
        (bool success, ) = receiver.call{value: amount}("");
        require(success, "Withdrawal failed");
    }
}