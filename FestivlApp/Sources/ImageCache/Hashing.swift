//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/9/22.
//

import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

import CryptoKit

enum Hashing {
    static func md5(for string: String) -> String {

        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
