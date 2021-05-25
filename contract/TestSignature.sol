pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./LibRichErrors.sol";
import "./LibOrder.sol";
import "./LibExchangeRichErrors.sol";
import "./LibEIP712.sol";

contract TestSignature {

    SignatureType public signatureT;

    enum SignatureType {
        Illegal,                     // 0x00, default value
        Invalid,                     // 0x01
        EIP712,                      // 0x02
        EthSign,                     // 0x03
        Wallet,                      // 0x04
        Validator,                   // 0x05
        PreSigned,                   // 0x06
        EIP1271Wallet,               // 0x07
        NSignatureTypes              // 0x08, number of signature types. Always leave at end.
    }

    function _isValidOrderWithHashSignature(
        LibOrder.Order memory order,
        bytes32 orderHash,
        bytes memory signature
    )
        internal
        returns (bool isValid)
    {
        address signerAddress = order.makerAddress;
        SignatureType signatureType = _readValidSignatureType(
            orderHash,
            signerAddress,
            signature
        );
        // if (signatureType == SignatureType.Validator) {
        //     // The entire order is verified by a validator contract.
        //     isValid = _validateBytesWithValidator(
        //         _encodeEIP1271OrderWithHash(order, orderHash),
        //         orderHash,
        //         signerAddress,
        //         signature
        //     );
        // } else if (signatureType == SignatureType.EIP1271Wallet) {
        //     // The entire order is verified by a wallet contract.
        //     isValid = _validateBytesWithWallet(
        //         _encodeEIP1271OrderWithHash(order, orderHash),
        //         signerAddress,
        //         signature
        //     );
        // } else {
        //     // Otherwise, it's one of the hash-only signature types.
        //     isValid = _validateHashSignatureTypes(
        //         signatureType,
        //         orderHash,
        //         signerAddress,
        //         signature
        //     );
        // }
        return true;
    }

    function _readValidSignatureType(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        private
        returns (SignatureType signatureType)
    {
        // Read the signatureType from the signature
        signatureType = _readSignatureType(
            hash,
            signerAddress,
            signature
        );

        signatureT = signatureType;

        // Disallow address zero because ecrecover() returns zero on failure.
        if (signerAddress == address(0)) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.INVALID_SIGNER,
                hash,
                signerAddress,
                signature
            ));
        }

        // Ensure signature is supported
        if (uint8(signatureType) >= uint8(SignatureType.NSignatureTypes)) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.UNSUPPORTED,
                hash,
                signerAddress,
                signature
            ));
        }

        // Always illegal signature.
        // This is always an implicit option since a signer can create a
        // signature array with invalid type or length. We may as well make
        // it an explicit option. This aids testing and analysis. It is
        // also the initialization value for the enum type.
        if (signatureType == SignatureType.Illegal) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.ILLEGAL,
                hash,
                signerAddress,
                signature
            ));
        }

        return signatureType;
    }

    function _readSignatureType(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        private
        pure
        returns (SignatureType)
    {
        if (signature.length == 0) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.INVALID_LENGTH,
                hash,
                signerAddress,
                signature
            ));
        }
        return SignatureType(uint8(signature[signature.length - 1]));
    }

}
