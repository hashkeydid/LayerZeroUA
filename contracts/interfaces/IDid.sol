// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface IDid {

    struct KYCInfo {
        bool status;
        uint updateTime;
        uint expireTime;
    }

    function addKYC(
        uint256 tokenId,
        address KYCProvider,
        uint256 KYCId,
        bool status,
        uint256 updateTime,
        uint256 expireTime,
        bytes memory evidence
    ) external;

    function did2TokenId(string memory did) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function getKYCInfo(uint256 tokenId, address KYCProvider, uint256 KYCId) external view returns (bool, uint256, uint256);

    function tokenId2Did(uint256 tokenId) external view returns (string memory);

    function signer() external view returns (address);
    
    function mintDidLZ(
        uint256 tokenId,
        address user,
        string memory did, 
        string memory avatar,
        address[] memory KYCProvider,
        uint256[] memory KYCId,
        KYCInfo[] memory KYCInfos,
        bytes[] memory evidence) external;
}
