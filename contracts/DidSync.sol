// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "./lzApp/NonblockingLzAppUpgradeable.sol";
import "./interfaces/IDid.sol";
import "./SyncStorage.sol";

struct Payload {
    uint256 tokenId;
    address user;
    string did;
    string avatar;
    address[] KYCProvider;
    uint256[] KYCId;
    IDid.KYCInfo[] KYCInfo;
    bytes[] evidence;
    bytes evidenceLZ;
    bytes nonEVMAddress;    
}

contract DidSync is NonblockingLzAppUpgradeable, SyncStorage {
    ///@dev Emmited when user sync KYC information
    event SendToChain(address user, uint16 indexed dstChainId, uint256 tokenId, bytes nonEVMAddress);
    event ReceiveFromChain(
        uint16 _srcChainId,
        bytes srcAddress,
        uint256 tokenId,
        uint64 nonce
    );

    /// @dev Initialize only once
    /// @param _endpoint LzApp endpoint
    function initialize(address _endpoint, address _did) public initializer {
        did = _did;
        adapterParams = abi.encodePacked(uint16(1), uint(2000000));
        __Ownable_init();
        __NonblockingLzAppUpgradeable_init(_endpoint);
    }

    function setAdapterParams(
        uint16 version,
        uint gasForDestinationLzReceive
    ) public onlyOwner {
        adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);
    }

    function setMaxKYCNumberWithGas(
        uint256 _maxKYCNumber,
        uint16 version,
        uint gasForDestinationLzReceive
    ) public onlyOwner {
        maxKYCNumber = _maxKYCNumber;
        adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);
    }

    /// @dev Sync KYC information to other chains
    /// @param _dstChainId Destination chain id
    /// @param _payload transfer payload
    function sync(Payload memory _payload, uint16 _dstChainId) public payable {
        require(
            IDid(did).ownerOf(_payload.tokenId) == msg.sender &&
                _payload.user == msg.sender &&
                keccak256(abi.encodePacked(_payload.did)) ==
                keccak256(
                    abi.encodePacked(IDid(did).tokenId2Did(_payload.tokenId))
                ),
            "DidSync: not owner or invalid args"
        );
        require(
            _validate(
                keccak256(
                    abi.encodePacked(
                        _payload.user,
                        _payload.tokenId,
                        _payload.did
                    )
                ),
                _payload.evidenceLZ,
                IDid(did).signer()
            ),
            "DidSync: invalid signature"
        );
        bytes memory payload = abi.encode(_payload);
        // _dstChainId: layer zero trusted remote chain id, initialized PlatON as 100.
        // block.chainid: PlatON chain id.
        // testnet
        // if (_dstChainId != 10120 && block.chainid != 2206132 && _dstChainId != 10119 && block.chainid != 16688 && _dstChainId != 10118)
       if (_dstChainId != 100 && block.chainid != 210425 && _dstChainId != 99 && block.chainid != 6688 && _dstChainId != 98) {
            _lzSend(
                _dstChainId,
                payload,
                payable(msg.sender),
                address(0x0),
                adapterParams
            );
        } else {
            (bool sent, ) = payable(did).call{value: msg.value}("");
            require(sent, "Failed to send Ether");
        }
        emit SendToChain(msg.sender, _dstChainId, _payload.tokenId, _payload.nonEVMAddress);
    }

    /// @dev Receive KYC information from other chains
    /// @param _payload Payload
    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal override {
        Payload memory payload = abi.decode(_payload, (Payload));
        require(
            _validate(
                keccak256(
                    abi.encodePacked(payload.user, payload.tokenId, payload.did)
                ),
                payload.evidenceLZ,
                IDid(did).signer()
            ),
            "DidSync: invalid signature"
        );
        require(
            payload.KYCProvider.length <= maxKYCNumber,
            "DidSync: invalid KYCProvider length"
        );
        IDid(did).mintDidLZ(
            payload.tokenId,
            payload.user,
            payload.did,
            payload.avatar,
            payload.KYCProvider,
            payload.KYCId,
            payload.KYCInfo,
            payload.evidence
        );
        emit ReceiveFromChain(
            _srcChainId,
            _srcAddress,
            payload.tokenId,
            _nonce
        );
    }

    function estimateSendFee(
        Payload memory _payload,
        uint16 _dstChainId,
        bool _useZro,
        bytes memory _adapterParams
    ) public view virtual returns (uint nativeFee, uint zroFee) {
        // mock the payload for send()
        bytes memory payload = abi.encode(_payload);
        return
            lzEndpoint.estimateFees(
                _dstChainId,
                address(this),
                payload,
                _useZro,
                _adapterParams
            );
    }

    /// @dev validate signature msg
    function _validate(
        bytes32 message,
        bytes memory signature,
        address signer
    ) internal pure returns (bool) {
        require(signer != address(0) && signature.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v = uint8(signature[64]) + 27;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
        }
        return ecrecover(message, v, r, s) == signer;
    }
}
