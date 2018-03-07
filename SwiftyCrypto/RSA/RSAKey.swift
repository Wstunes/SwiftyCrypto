//
//  RSAKeyPair.swift
//  SwiftyCrypto
//
//  Created by Shuo Wang on 2018/1/15.
//  Copyright © 2018年 Yufu. All rights reserved.
//

import Foundation

public enum RSAKeyType {
    case PUBLIC
    case PRIVATE
}

public struct RSAKeyPair {
    public var privateKey: RSAKey
    public var publicKey: RSAKey
}

public class RSAKey {
    public var key: SecKey
    public var keyBase64String: String
    public var data: Data?
    public var keyType: RSAKeyType!

    public init(key: SecKey, keyBase64String: String, keyType: RSAKeyType) {
        self.key = key
        self.keyBase64String = keyBase64String
        self.keyType = keyType
    }

    public init(base64String: String, keyType: RSAKeyType) throws {
        self.keyType = keyType
        let formatedString = try RSAKey.base64StringWithoutPrefixAndSuffix(pemString: base64String)

        self.keyBase64String = formatedString
        guard let data = Data(base64Encoded: formatedString, options: [.ignoreUnknownCharacters]) else {
            throw SwiftyCryptoError.invalidBase64String
        }
        self.data = data
        let dataWithoutHeader = try RSAUtils.stripKeyHeader(keyData: data)
        self.key = try RSAUtils.secKeyFromData(keyData: dataWithoutHeader, keyType: keyType, tag: UUID().uuidString)
    }

    public static func base64StringWithoutPrefixAndSuffix(pemString: String) throws -> String {
        let lines = pemString.components(separatedBy: "\n").filter { line in
            return !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END")
        }

        guard lines.count != 0 else {
            throw SwiftyCryptoError.invalidKeyFormat
        }

        return lines.joined(separator: "")
    }

    public func pemString() throws -> String {
        let data = try self.data(forKeyReference: self.key)
        let pem = self.format(keyData: data, keyType: self.keyType)
        return pem
    }

    func data(forKeyReference reference: SecKey) throws -> Data {

        // On iOS+, we can use `SecKeyCopyExternalRepresentation` directly
        if #available(iOS 10.0, *), #available(watchOS 3.0, *), #available(tvOS 10.0, *) {

            var error: Unmanaged<CFError>? = nil
            let data = SecKeyCopyExternalRepresentation(reference, &error)
            guard let unwrappedData = data as Data? else {
                throw SwiftyCryptoError.keyRepresentationFailed(error: error?.takeRetainedValue())
            }
            return unwrappedData

            // On iOS 8/9, we need to add the key again to the keychain with a temporary tag, grab the data,
            // and delete the key again.
        } else {

            let temporaryTag = UUID().uuidString
            let addParams: [CFString: Any] = [
                kSecValueRef: reference,
                kSecReturnData: true,
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: temporaryTag
            ]

            var data: AnyObject?
            let addStatus = SecItemAdd(addParams as CFDictionary, &data)
            guard let unwrappedData = data as? Data else {
                throw SwiftyCryptoError.keyAddFailed(status: addStatus)
            }

            let deleteParams: [CFString: Any] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: temporaryTag
            ]

            _ = SecItemDelete(deleteParams as CFDictionary)

            return unwrappedData
        }
    }

    public func format(keyData: Data, keyType: RSAKeyType) -> String {

        let pemType = keyType == .PRIVATE ? "RSA PRIVATE KEY" : "PUBLIC KEY"

        func split(_ str: String, byChunksOfLength length: Int) -> [String] {
            return stride(from: 0, to: str.count, by: length).map { index -> String in
                let startIndex = str.index(str.startIndex, offsetBy: index)
                let endIndex = str.index(startIndex, offsetBy: length, limitedBy: str.endIndex) ?? str.endIndex
                return String(str[startIndex..<endIndex])
            }
        }

        // Line length is typically 64 characters, except the last line.
        // See https://tools.ietf.org/html/rfc7468#page-6 (64base64char)
        // See https://tools.ietf.org/html/rfc7468#page-11 (example)
        let chunks = split(keyData.base64EncodedString(), byChunksOfLength: 64)

        let pem = [
            "-----BEGIN \(pemType)-----",
            chunks.joined(separator: "\n"),
            "-----END \(pemType)-----"
        ]

        return pem.joined(separator: "\n")
    }
}
