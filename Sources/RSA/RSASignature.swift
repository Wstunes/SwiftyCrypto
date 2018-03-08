//
//  RSASignature.swift
//  SwiftyCrypto
//
//  Created by Shuo Wang on 2018/1/16.
//  Copyright © 2018年 Yufu. All rights reserved.
//

import Foundation

public class RSASignature {
    
    public enum DigestType {
        case sha1
        case sha224
        case sha256
        case sha384
        case sha512
        
        var padding: SecPadding {
            switch self {
            case .sha1: return .PKCS1SHA1
            case .sha224: return .PKCS1SHA224
            case .sha256: return .PKCS1SHA256
            case .sha384: return .PKCS1SHA384
            case .sha512: return .PKCS1SHA512
            }
        }
    }
    
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public convenience init(base64Encoded base64String: String) throws {
        guard let data = Data(base64Encoded: base64String) else {
            throw SwiftyCryptoError.invalidBase64String
        }
        self.init(data: data)
    }
    
    public var base64String: String {
        return data.base64EncodedString()
    }
}
