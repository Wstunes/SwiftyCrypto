//
//  SwiftyCryptoError.swift
//  SwiftyCrypto
//
//  Created by Shuo Wang on 2018/1/16.
//  Copyright © 2018年 Yufu. All rights reserved.
//

import Foundation

public enum SwiftyCryptoError: Error {
    case invalidBase64String
    case invalidKeyFormat
    case invalidAsn1Structure
    case asn1ParsingFailed
    case invalidAsn1RootNode
    case tagEncodingFailed
    case keyCreateFailed(error: CFError?)
    case keyAddFailed(status: OSStatus)
    case keyCopyFailed(status: OSStatus)
    case invalidDigestSize(digestSize: Int, maxChunkSize: Int)
    case signatureCreateFailed(status: OSStatus)
    case signatureVerifyFailed(status: OSStatus)
    case keyRepresentationFailed(error: CFError?)
}
