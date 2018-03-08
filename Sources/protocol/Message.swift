//
//  Message.swift
//  SwiftyCrypto
//
//  Created by Shuo Wang on 2018/1/16.
//  Copyright © 2018年 Yufu. All rights reserved.
//

import Foundation

public protocol Message {
    var data: Data { get }
    var base64String: String { get }
    init(data: Data)
    init(base64String: String) throws
}

public extension Message {
    var base64String: String {
        return data.base64EncodedString()
    }
}
