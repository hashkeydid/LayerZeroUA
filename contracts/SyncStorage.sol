// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

/// @title A storage contract for didv2
/// @dev include mapping from id to address and address to id
contract SyncStorage {
    address public did;
    bytes public adapterParams;
    uint256 public maxKYCNumber;
}