// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftTest is ERC721, Ownable {
    
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public mintPrice;
    uint256 public maxPerWallet;
    bool public isMintEnabled;
    bool public onlyWhitelisted = true;
    bool public revealed;
    string public baseUri;
    string public notRevealedUri;
    address payable public withdrawWallet;
    address[] public allWhitelist;
    mapping(address => uint256) mintedWallets;
    
    constructor() ERC721("VajaNft", "VN") {
        totalSupply = 0;
        maxSupply = 20;
        mintPrice = 0.02 ether;
        maxPerWallet = 2;
        setBaseUri(baseUri);
        setNotRevealedUri(notRevealedUri);
        mint(5);
    }

    function setIsMintEnabled(bool mintEnabled_) external onlyOwner {
        isMintEnabled = mintEnabled_;
    }

    function setBaseUri(string memory baseUri_) public onlyOwner {
        baseUri = baseUri_;
    }

    function setNotRevealedUri(string memory notRevealedUri_) public onlyOwner {
        notRevealedUri = notRevealedUri_;
    }

    function tokenURI(uint256 tokenId_) view public override returns (string memory) {
        require(_exists(tokenId_));
        if (revealed == false) {
            return notRevealedUri;
        }
        return string(abi.encodePacked(baseUri, Strings.toString(tokenId_), ".json"));
    }

    function withdraw() public onlyOwner {
        (bool success, ) = payable(owner()).call{ value: address(this).balance }("");
        require(success, "fail");
    }

    function mint(uint256 _quantity) payable public {
        require(totalSupply + _quantity <= maxSupply, "sold out");

        if (msg.sender != owner()) {
            require(mintedWallets[msg.sender] + _quantity <= maxPerWallet, "exceed per wallet");
            require(msg.value == mintPrice * _quantity, "wrong price");
            require(isMintEnabled, "not enabled");
            if (onlyWhitelisted == true) {
                require(setIsWhitelisted(msg.sender), "not whitelisted");
            }
        }

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 newToken = totalSupply + 1;
            totalSupply++;
            mintedWallets[msg.sender]++;
            _safeMint(msg.sender, newToken);
        }
    }

    function setIsWhitelisted(address whitelist_) view public returns (bool) {
        for (uint256 i = 0; i < allWhitelist.length; i++) {
            if (allWhitelist[i] == whitelist_) {
                return true;
            }
        }
        return false;
    }

    function setRevealed() public onlyOwner {
        revealed = true;
    }

    function setOnlyWhitelisted() public onlyOwner {
        onlyWhitelisted = false;
    }

    function createWhitelist(address[] calldata createWhitelist_) public onlyOwner {
        delete allWhitelist;
        allWhitelist = createWhitelist_;
    }
}