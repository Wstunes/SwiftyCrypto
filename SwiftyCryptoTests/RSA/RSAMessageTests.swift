//
//  RSAMessageTests.swift
//  SwiftyCryptoTests
//
//  Created by Shuo Wang on 2018/1/16.
//  Copyright © 2018年 Yufu. All rights reserved.
//

import XCTest
@testable import SwiftyCrypto

class RSAMessageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
 
    func testInitRSAMessage() {
        let failMessage = try? RSAMessage.init(base64String: "aa")
        XCTAssert(nil == failMessage)
        
        let successMessage = try? RSAMessage.init(base64String: "aGVsbG8=")
        XCTAssert(successMessage?.base64String == "aGVsbG8=")
        XCTAssert(String.init(data: (successMessage?.data)!, encoding: String.Encoding.utf8) == "hello")
    }
}
