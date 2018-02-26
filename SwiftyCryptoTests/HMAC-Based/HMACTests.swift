//
//  HSTests.swift
//  SwiftyCryptoTests
//
//  Created by Shuo Wang on 2018/2/26.
//  Copyright © 2018年 Yufu. All rights reserved.
//

import XCTest

class HMACTests: XCTestCase {
    
    fileprivate let key = "wangshuowq"
    fileprivate let message = "toBeEncrypted"
    fileprivate var messageData: Data!
    fileprivate var keyData: Data!
    
    override func setUp() {
        super.setUp()
        messageData = message.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        keyData = key.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }

    func testHMAC() {
        let hashed256Data = hmac(algorithm: .sha256, key: keyData, message: messageData)
        XCTAssert(hashed256Data.base64EncodedString() == "rqUSrJIFTB20ApclxcFWKoH1MG5YW/5bNPANE0ahqy0=")
        
        let hashed384Data = hmac(algorithm: .sha384, key: keyData, message: messageData)
        XCTAssert(hashed384Data.base64EncodedString() == "tVwieuaBhvluGfymPyaymCH+S/FaZwDg/QLlYyVq9IN9A2E229UiEtYpx/do8q0W")
        
        let hashed512Data = hmac(algorithm: .sha512, key: keyData, message: messageData)
        XCTAssert(hashed512Data.base64EncodedString() == "XpHwXQ+yOO1qR3sd9sOFpkiQAbGtorYLr/vd/vCxF38mJfwQnB9LVEuNxRLKAurv45Jc4SZRaZ84VPmYMC53cg==")
    }

}
