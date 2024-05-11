// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Script, console} from "forge-std/Script.sol";
import {Script, console} from "../lib/forge-std/src/Script.sol";
import "../src/token_nft/ERC20.sol";
import "../src/token_nft/IERC721.sol";

import {Upgrades,Options} from "../lib/openzeppelin-foundry-upgrades/src/Upgrades.sol";

import {NFTMarketV1} from "../src/NFTMarketV1.sol";
import {NFTMarketV2} from "../src/NFTMarketV2.sol";

contract MyScript is Script {
    function run() external {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address admin = vm.envAddress("ADDRESS");

        address token = address(0x552DFF72A5caC04bDe5CA0E5C6D33b9bA3AF115b);
        address nft = address(0xB58e257506bAE4a6b3Ac6b369Ff4B6fFa7BE7332);

        vm.startBroadcast(deployerPrivateKey);

        address proxy = Upgrades.deployTransparentProxy(
        "NFTMarketV1.sol",
        admin,
        abi.encodeCall(NFTMarketV1.initialize, (token, nft))
);
        NFTMarketV1 nftMarketV1 = NFTMarketV1(proxy);

        Options memory opts;
        opts.referenceContract = "NFTMarketV1.sol";
        Upgrades.upgradeProxy(proxy, "NFTMarketV2.sol", "", opts);

        vm.stopBroadcast();
    }
}
