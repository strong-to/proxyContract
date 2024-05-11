// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./NFTMarketV1.sol";
import {ECDSA} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

/// @custom:oz-upgrades-from NftMarketV1
contract NFTMarketV2 is NFTMarketV1{
    
    using ECDSA for bytes32;

    using MessageHashUtils for bytes32;

    function permitList(uint256 tokenId, uint256 price, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(deadline> block.timestamp, "expire signiture");
        // block.chanid 获取当前链的链id ； block 是一个全局变量有很多属性，block.number: 当前区块的块号（高度）、block.difficulty: 当前区块的难度。
        //block.gaslimit: 当前区块的 gas 限制。 block.coinbase: 当前区块的矿工地址，即将接收区块奖励的地址。
        uint chainId = block.chainid;

        // keccak256 是一种哈希算法，用于将任意长度的数据输入转换为固定长度的哈希值
        bytes32 eip712DomainHash = keccak256(
            // abi.encode 是 Solidity 中的一个函数，用于将参数编码为紧凑的字节序列（ABI 编码）
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("NFTMarketV2")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );  

        //List(address sender,uint256 tokenId, uint256 price, uint256 deadline)
        bytes32 hashStruct = keccak256(
        abi.encode(
            keccak256("List(address sender,uint256 tokenId, uint256 price, uint256 deadline)"),
            msg.sender,
            tokenId,
            price,
            deadline
            )
        );

        // abi.encodePacked: 将参数按照顺序紧密打包，不进行任何填充或对齐。这意味着各种数据类型的参数会直接按照其原始二进制格式编码，不进行额外处理。
        // abi.encode: 将参数进行动态编码，会在参数之间添加长度信息和对齐字节，以确保编码后的数据能够正确解析。这种编码方式适用于构建函数调用数据或创建动态数组等情况。

        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));
        address signer = hash.recover(v, r, s);
        require(signer == msg.sender, "invalid signature");

        list(tokenId, price);
    }

    // function marketVersion() override public pure returns (uint8){
    //     return 2;
    // }

}