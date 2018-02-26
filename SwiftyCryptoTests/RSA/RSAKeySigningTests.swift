//
//  SwiftyCryptoTests.swift
//  SwiftyCryptoTests
//
//  Created by Shuo Wang on 2018/1/15.
//  Copyright © 2018年 Yufu. All rights reserved.
//

import XCTest
@testable import SwiftyCrypto

class SwiftyCryptoRSATests: XCTestCase {

    let bundle = Bundle(for: SwiftyCryptoRSATests.self)
    var publicKeyString: String?
    var privateKeyString: String?

    override func setUp() {
        super.setUp()
        guard let publicPath = bundle.path(forResource: "public", ofType: "txt"),
            let privatePath = bundle.path(forResource: "private", ofType: "txt")
            else {
                return XCTFail()
        }
        publicKeyString = try? String(contentsOf: URL(fileURLWithPath: publicPath), encoding: .utf8)
        privateKeyString = try? String(contentsOf: URL(fileURLWithPath: privatePath), encoding: .utf8)
        guard let _ = publicKeyString,
            let _ = privateKeyString else {
                return XCTFail()
        }
    }

    func testGenerateRSAKeyPair() {
        let keyPair = RSAKeyFactory.shared.generateKeyPair(keySize: .RSAKey256)
        XCTAssert(nil != keyPair)
    }

    func testGenerateRSAKeyFromFactoryKeys() {
        let keyPair = RSAKeyFactory.shared.generateKeyPair(keySize: .RSAKey256)
        XCTAssert(nil != keyPair)

        let publicKey = try? RSAKey.init(base64String: (keyPair?.publicKey.keyBase64String)!, keyType: .PUBLIC)
        XCTAssert(nil != publicKey)

        let privateKey = try? RSAKey.init(base64String: (keyPair?.privateKey.keyBase64String)!, keyType: .PRIVATE)
        XCTAssert(nil != privateKey)
    }

    func testGenerateRSAKeyAndSignAndVerify() {
        let keyPair = RSAKeyFactory.shared.generateKeyPair(keySize: .RSAKey256)

        let publicKey = try? RSAKey.init(base64String: publicKeyString!, keyType: .PUBLIC)
        XCTAssert(nil != publicKey)

        let privateKey = try? RSAKey.init(base64String: privateKeyString!, keyType: .PRIVATE)
        XCTAssert(nil != privateKey)

        // rawData :{"alg":"RS256","typ":"JWT"}
        // Base64ed :eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6InNodW93YW5nIiwiYWRtaW4iOnRydWV9
        let messageTobeSigned = try? RSAMessage.init(base64String: "ZXlKaGJHY2lPaUpTVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnpkV0lpT2lJeE1qTTBOVFkzT0Rrd0lpd2libUZ0WlNJNkluTm9kVzkzWVc1bklpd2lZV1J0YVc0aU9uUnlkV1Y5")
        XCTAssert(nil != messageTobeSigned)

        let signature = try? messageTobeSigned?.sign(signingKey: privateKey!, digestType: RSASignature.DigestType.sha256)
        XCTAssert(nil != signature)
        XCTAssert("KR7KPmWtY46Bc3tal4CoNSHGVLh7jgJC1+AlRzBxFw0/4HNBa5a4/Gynb2PG9RljvnppM+Uy9TX2WitHIh9zE/OxaP0faQ/Lc2GyIcX0CBrz4IZ0O0Ky/w1g5ugaT+XoKOzZlUso1F5Nr/waYVyWW57wdtf+BXDoOkj33iAPi/lqFpQrdD501MOs0rrttunJWs/X684jJr7aew8cs1JXNn91+krRt/z8VFJkgYClnfdAc6SPSbHQZPQB1kxApHANJYZEUOyiHn4AUhqnJ9IlWHKJl2KUKIqEVyKQWimoGIT2Sj6xBtIu4Zmx81fmyL1K3HksLCgbxYR03PGqN+WH1g==" == signature!!.base64String)

        // successful verification
        XCTAssert(true == (try! messageTobeSigned?.verify(verifyKey: publicKey!, signature: signature!!, digestType: RSASignature.DigestType.sha256))!)

        // failed verification
        XCTAssert(false == (try! messageTobeSigned?.verify(verifyKey: keyPair!.publicKey, signature: signature!!, digestType: RSASignature.DigestType.sha256))!)
    }

}
