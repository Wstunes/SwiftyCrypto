//
//  RSAKeyFactory.swift
//  SwiftyCrypto
//
//  Created by Shuo Wang on 2018/1/15.
//  Copyright © 2018年 Yufu. All rights reserved.
//

public enum SwiftyCryptoRSAKeySize: Int {
    case RSAKey64 = 512
    case RSAKey128 = 1024
    case RSAKey256 = 2048
    case RSAKey512 = 4096
}

public class RSAKeyFactory: NSObject {
    public static let shared = RSAKeyFactory()

    public func generateKeyPair(keySize: SwiftyCryptoRSAKeySize) -> RSAKeyPair? {
        let publicKeyTag = UUID().uuidString
        let privateKeyTag = UUID().uuidString

        let publicKeyAttr: [NSString: Any] = [
            kSecAttrIsPermanent: NSNumber(value: true),
            kSecAttrApplicationTag: publicKeyTag.data(using: .utf8) as Any,
            kSecAttrAccessible: kSecAttrAccessibleAlways
        ]
        let privateKeyAttr: [NSString: Any] = [
            kSecAttrIsPermanent: NSNumber(value: true),
            kSecAttrApplicationTag: privateKeyTag.data(using: .utf8) as Any,
            kSecAttrAccessible: kSecAttrAccessibleAlways
        ]

        let keyPairAttr: [NSString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: keySize.rawValue,
            kSecPublicKeyAttrs: publicKeyAttr,
            kSecPrivateKeyAttrs: privateKeyAttr
        ]

        var publicKey: SecKey?
        var privateKey: SecKey?
        var statusCode: OSStatus
        statusCode = SecKeyGeneratePair(keyPairAttr as CFDictionary, &publicKey, &privateKey)

        if statusCode == noErr,
            let priKey = privateKey,
            let pubKey = publicKey {
            return RSAKeyPair.init(privateKey: RSAKey.init(key: priKey, keyBase64String: secKeyToBase64String(secAttrApplicationTag: privateKeyTag), keyType: .PRIVATE),
                publicKey: RSAKey.init(key: pubKey, keyBase64String: secKeyToBase64String(secAttrApplicationTag: publicKeyTag), keyType: .PUBLIC))
        } else {
            print("Error generating key pair: \(statusCode)")
        }

        return nil
    }

    func secKeyToBase64String(secAttrApplicationTag: String) -> String {
        var dataPtr: AnyObject?
        let query: [NSString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: secAttrApplicationTag,
            kSecReturnData: NSNumber(value: true)
        ]
        let statusCode = SecItemCopyMatching(query as CFDictionary, &dataPtr)

        if statusCode == noErr,
            let keyData = dataPtr as? Data {

            let keyString = keyData.base64EncodedString()
            return keyString
        }
        return ""
    }

}
