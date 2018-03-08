//
//  RSAMessage.swift
//  SwiftyCrypto
//
//  Created by Shuo Wang on 2018/1/16.
//  Copyright © 2018年 Yufu. All rights reserved.
//

import Foundation

public class RSAMessage: Message {
    public var data: Data
    
    public var base64String: String
    
    public required init(data: Data) {
        self.data = data
        self.base64String = data.base64EncodedString()
    }
    
    public required convenience init(base64String: String) throws {
        guard let data = Data(base64Encoded: base64String) else {
            throw SwiftyCryptoError.invalidBase64String
        }
        self.init(data: data)
    }
    
    public func sign(signingKey: RSAKey, digestType: RSASignature.DigestType) throws -> RSASignature {
        
        let digest = self.digest(digestType: digestType)
        let blockSize = SecKeyGetBlockSize(signingKey.key)
        let maxChunkSize = blockSize - 11
        
        guard digest.count <= maxChunkSize else {
            throw SwiftyCryptoError.invalidDigestSize(digestSize: digest.count, maxChunkSize: maxChunkSize)
        }
        
        var digestBytes = [UInt8](repeating: 0, count: digest.count)
        (digest as NSData).getBytes(&digestBytes, length: digest.count)
        
        var signatureBytes = [UInt8](repeating: 0, count: blockSize)
        var signatureDataLength = blockSize
        
        let status = SecKeyRawSign(signingKey.key, digestType.padding, digestBytes, digestBytes.count, &signatureBytes, &signatureDataLength)
        
        guard status == noErr else {
            throw SwiftyCryptoError.signatureCreateFailed(status: status)
        }
        
        let signatureData = Data(bytes: UnsafePointer<UInt8>(signatureBytes), count: signatureBytes.count)
        return RSASignature(data: signatureData)
    }
    
    public func verify(verifyKey: RSAKey, signature: RSASignature, digestType: RSASignature.DigestType) throws -> Bool {
        
        let digest = self.digest(digestType: digestType)
        var digestBytes = [UInt8](repeating: 0, count: digest.count)
        (digest as NSData).getBytes(&digestBytes, length: digest.count)
        
        var signatureBytes = [UInt8](repeating: 0, count: signature.data.count)
        (signature.data as NSData).getBytes(&signatureBytes, length: signature.data.count)
        
        let status = SecKeyRawVerify(verifyKey.key, digestType.padding, digestBytes, digestBytes.count, signatureBytes, signatureBytes.count)
        
        if status == errSecSuccess {
            return true
        } else if status == -9809 {
            return false
        } else {
            throw SwiftyCryptoError.signatureVerifyFailed(status: status)
        }
    }
    
    func digest(digestType: RSASignature.DigestType) -> Data {
        
        let digest: Data
        
        switch digestType {
        case .sha1:
            digest = (data as NSData).sha1
        case .sha224:
            digest = (data as NSData).sha224
        case .sha256:
            digest = (data as NSData).sha256
        case .sha384:
            digest = (data as NSData).sha384
        case .sha512:
            digest = (data as NSData).sha512
        }
        
        return digest
    }
}
