//
//  NSDataExtension.swift
//  SwiftyCrypto-iOS
//
//  Created by Shuo Wang on 2018/3/8.
//  Copyright © 2018年 Yufu. All rights reserved.
//

import Foundation
import CommonCrypto

extension NSData {
    var sha1: Data {
        let outputLength = Int(CC_SHA1_DIGEST_LENGTH);
        var digest = [UInt8](repeating: 0, count: outputLength)

        CC_SHA1(self.bytes, CC_LONG(self.length), &digest)
        return Data.init(bytes: &digest, count: outputLength)
    }

    var sha224: Data {
        let outputLength = Int(CC_SHA224_DIGEST_LENGTH);
        var digest = [UInt8](repeating: 0, count: outputLength)

        CC_SHA224(self.bytes, CC_LONG(self.length), &digest)
        return Data.init(bytes: &digest, count: outputLength)
    }

    var sha256: Data {
        let outputLength = Int(CC_SHA256_DIGEST_LENGTH);
        var digest = [UInt8](repeating: 0, count: outputLength)

        CC_SHA256(self.bytes, CC_LONG(self.length), &digest)
        return Data.init(bytes: &digest, count: outputLength)
    }

    var sha384: Data {
        let outputLength = Int(CC_SHA384_DIGEST_LENGTH);
        var digest = [UInt8](repeating: 0, count: outputLength)

        CC_SHA384(self.bytes, CC_LONG(self.length), &digest)
        return Data.init(bytes: &digest, count: outputLength)
    }

    var sha512: Data {
        let outputLength = Int(CC_SHA512_DIGEST_LENGTH);
        var digest = [UInt8](repeating: 0, count: outputLength)

        CC_SHA512(self.bytes, CC_LONG(self.length), &digest)
        return Data.init(bytes: &digest, count: outputLength)
    }
}
