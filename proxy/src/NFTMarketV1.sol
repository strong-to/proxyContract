//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
// import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract NFTMarketV1 {
    mapping(uint => uint) public tokenIdPrice;
    mapping(uint => address) public tokenSeller; // 卖方
    address public  token;
    address public  nftToken;

    address public admin;

    // constructor(address _token, address _nftToken) {
    //     token = _token;
    //     nftToken = _nftToken;
    // }

    function initialize(address _token, address _nft)  public {

        token = _token;
        nftToken = _nft;

        admin = msg.sender;
    }

    // function onERC721Received(
    //     address operator,
    //     address from,
    //     uint256 tokenId,
    //     bytes calldata data
    // ) external override returns (bytes4) {
    //   return this.onERC721Received.selector;
    // }

    // approve(address to, uint256 tokenId) first
    function list(uint tokenID, uint amount) public {

        IERC721(nftToken).safeTransferFrom(msg.sender, address(this), tokenID, "");

        tokenIdPrice[tokenID] = amount;
        tokenSeller[tokenID] = msg.sender;
    }

    function buy(uint tokenId, uint amount) external {

      require(amount >= tokenIdPrice[tokenId], "low price");
      require(IERC721(nftToken).ownerOf(tokenId) == address(this), "aleady selled");

      IERC20(token).transferFrom(msg.sender, tokenSeller[tokenId], tokenIdPrice[tokenId]);  // token 
      IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);  // nft
      
    }


}

// 编写一个简单的NFT市场合约，使用自己发行的Token来买卖NFT，函数的方法有：
// list()：实现上架功能，NFT持有者可以设定一个价格（需要多少个代币购买该NFT）并上架NFT到NFT市场。
// buyNFT()：实现购买NFT功能，用户转入所定价的代币数量，获得对应的NFT。