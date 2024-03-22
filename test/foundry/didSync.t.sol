// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.2;

// import { Resolver } from "/Users/quanrong/hashkeydid-workplace/resolver/contracts/Resolver.sol";
// import { DidV2 } from "/Users/quanrong/hashkeydid-workplace/hashkeydid-contracts/contracts/Did.sol";
// import "../../contracts/DidSync.sol";
// import "../../contracts/SendLibrary.sol";
// import { Endpoint } from "../../contracts/Endpoint.sol";
// import "forge-std/Test.sol";


// contract DidSyncTest is Test {

//     DidSync didSync;
//     DidV2 did;
//     Endpoint endpoint;
//     Resolver resolver;
//     SendLibrary sendLibrary;
//     address owner = address(this);
//     uint256 signerPri = 0xAA;
//     address signer = vm.addr(signerPri);

//     function setUp() public {
//         did = new DidV2();
//         did.initialize("Did","Did","baseuri",owner);
//         endpoint = new Endpoint(1);
//         didSync = new DidSync();
//         resolver = new Resolver();
//         resolver.initialize(address(did));
//         didSync.initialize(address(endpoint), address(did));
//         did.setResolverAddr(address(resolver));
//         did.setDidSync(address(didSync));
//         did.setSigner(signer);
//         didSync.setTrustedRemote(2, abi.encodePacked(uint16(2), uint16(1)));
//         sendLibrary = new SendLibrary();
//         endpoint.newVersion(address(sendLibrary));
//         endpoint.setDefaultSendVersion(1);
//     }

//     function testSyncA() public payable {
//         uint256 expiredTimestamp = block.timestamp + 1 days;
//         console.log("test address", address(this));
//         bytes32 hash = keccak256(abi.encodePacked(address(this), block.chainid, expiredTimestamp, "did.key", msg.value));
//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPri, hash);
//         v = v - 27;
//         bytes memory signature = abi.encodePacked(r,s,v);
//         did.claim(expiredTimestamp, "did.key", signature, "avatar");
//         uint256 tokenId = did.did2TokenId("did.key");
//         bytes32 lzhash = keccak256(abi.encodePacked(address(this), tokenId, "did.key"));
//         (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(signerPri, lzhash);
//         v2 = v2 - 27;
//         bytes memory lzsignature = abi.encodePacked(r2,s2,v2);
//         Payload memory _payload = Payload(
//             tokenId,
//             address(this),
//             "did.key",
//             "avatar",
//             new address[](0),
//             new uint256[](0),
//             new IDid.KYCInfo[](0),
//             new bytes[](0),
//             lzsignature
//         );
//         didSync.syncA(_payload, 2);
//         assertEq(sendLibrary.isSend(), true);
//     }

//     function test
// }