//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";



contract MyToken is EIP712, ERC1155, Ownable {

    mapping(uint256 => string) public _uris;
    uint256 public testAmount = 1;
    mapping (uint256 => uint256) public mintedNfts;
    address public ownerr = 0x1B8163f3f7Ae29AF06c50dF4AE5E0Fe9375f8496;

    mapping(uint256 => address) public allOwners;

    mapping (address => uint256) pendingWithdrawals;


    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private constant SIGNING_DOMAIN = "Voucher-Domain";
    string private constant SIGNATURE_VERSION = "1";

    struct LazyNFTVoucher {
        uint256 tokenId;
        uint256 price;
        string uri;
        bytes signature;
    }

    constructor() ERC1155("") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {}

    function uri(uint256 tokenId) override public view returns (string memory) {
        return(_uris[tokenId]);
    }

    function setTokenUri(uint256 tokenId, string memory urii) public {
        _uris[tokenId] = urii;
    }

    function mint(LazyNFTVoucher calldata voucher)
        public payable
        
    {   
        address signer = recover(voucher);
        require(signer == ownerr, "not owner");
        require(mintedNfts[voucher.tokenId] < 3, "sold out");
        require(voucher.price >= msg.value, "not enough");
        mintedNfts[voucher.tokenId]++;
        _mint(msg.sender, voucher.tokenId, testAmount, "");
        setTokenUri(voucher.tokenId, voucher.uri);

        pendingWithdrawals[signer] += msg.value;

    }

    function recover(LazyNFTVoucher calldata voucher) public view returns (address) {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("LazyNFTVoucher(uint256 tokenId,uint256 price,string uri)"),
            voucher.tokenId,
            voucher.price,
            keccak256(bytes(voucher.uri))
        )));
        address signer = ECDSA.recover(digest, voucher.signature);
        return signer;
    }

    function addOwner(uint256 id, address _coOwner) public {
        allOwners[id] = _coOwner;
    }

    function zbrisi(uint256 id) public {
        delete allOwners[id];
    }

    function withdraw() public {
    
    // IMPORTANT: casting msg.sender to a payable address is only safe if ALL members of the minter role are payable addresses.
    address payable receiver = payable(msg.sender);

    uint amount = pendingWithdrawals[receiver];
    // zero account before transfer to prevent re-entrancy attack
    pendingWithdrawals[receiver] = 0;
    receiver.transfer(amount);
  }
}