//
//  RSAUtils.swift
//  SwiftyCrypto
//
//  Created by Shuo Wang on 2018/1/16.
//  Copyright © 2018年 Yufu. All rights reserved.
//

import Foundation

class RSAUtils {
    static func stripKeyHeader(keyData: Data) throws -> Data {

        let node: Asn1Parser.Node
        do {
            node = try Asn1Parser.parse(data: keyData)
        } catch {
            throw SwiftyCryptoError.asn1ParsingFailed
        }

        // Ensure the raw data is an ASN1 sequence
        guard case .sequence(let nodes) = node else {
            throw SwiftyCryptoError.invalidAsn1RootNode
        }

        // Detect whether the sequence only has integers, in which case it's a headerless key
        let onlyHasIntegers = nodes.filter { node -> Bool in
            if case .integer(_) = node { // swiftlint:disable:this unused_optional_binding
                return false
            }
            return true
        }.isEmpty

        // Headerless key
        if onlyHasIntegers {
            return keyData
        }

        // If last element of the sequence is a bit string, return its data
        if let last = nodes.last, case .bitString(let data) = last {
            return data
        }

        // If last element of the sequence is an octet string, return its data
        if let last = nodes.last, case .octetString(let data) = last {
            return data
        }

        // Unable to extract bit/octet string or raw integer sequence
        throw SwiftyCryptoError.invalidAsn1Structure
    }

    static func secKeyFromData(keyData: Data, keyType: RSAKeyType, tag: String) throws -> SecKey {

        var keyData = keyData

        guard let tagData = tag.data(using: .utf8) else {
            throw SwiftyCryptoError.tagEncodingFailed
        }
        let keyClass = keyType == .PRIVATE ? kSecAttrKeyClassPrivate : kSecAttrKeyClassPublic

        // On iOS 10+, we can use SecKeyCreateWithData without going through the keychain
        if #available(iOS 10.0, *), #available(watchOS 3.0, *), #available(tvOS 10.0, *) {

            let sizeInBits = keyData.count * 8
            let keyDict: [CFString: Any] = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: keyClass,
                kSecAttrKeySizeInBits: NSNumber(value: sizeInBits),
                kSecReturnPersistentRef: true
            ]

            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
                throw SwiftyCryptoError.keyCreateFailed(error: error?.takeRetainedValue())
            }
            return key

            // On iOS 9 and earlier, add a persistent version of the key to the system keychain
        } else {

            let persistKey = UnsafeMutablePointer<AnyObject?>(mutating: nil)

            let keyAddDict: [CFString: Any] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: tagData,
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecValueData: keyData,
                kSecAttrKeyClass: keyClass,
                kSecReturnPersistentRef: true,
                kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked
            ]

            let addStatus = SecItemAdd(keyAddDict as CFDictionary, persistKey)
            guard addStatus == errSecSuccess || addStatus == errSecDuplicateItem else {
                throw SwiftyCryptoError.keyAddFailed(status: addStatus)
            }

            let keyCopyDict: [CFString: Any] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: tagData,
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: keyClass,
                kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
                kSecReturnRef: true,
            ]

            // Now fetch the SecKeyRef version of the key
            var keyRef: AnyObject? = nil
            let copyStatus = SecItemCopyMatching(keyCopyDict as CFDictionary, &keyRef)

            guard let unwrappedKeyRef = keyRef else {
                throw SwiftyCryptoError.keyCopyFailed(status: copyStatus)
            }

            return unwrappedKeyRef as! SecKey
        }
    }
}
