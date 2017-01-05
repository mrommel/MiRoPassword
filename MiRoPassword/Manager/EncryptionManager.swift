//
//  EncryptionManager.swift
//  MiRoPassword
//
//  Created by Michael Rommel on 04.01.17.
//  Copyright © 2017 MiRo Soft. All rights reserved.
//

import Foundation
import CryptoSwift

public extension CSArrayType where Iterator.Element == UInt8 {
    
    public func toRawString() -> String {
        let hex = self.toHexString()

        let hexArray = splitedString(string: hex, length: 2)
        
        let charArray = hexArray.map { char -> Character in
            let code = Int(strtoul(char, nil, 16))
            if code != 5 {
                return Character(UnicodeScalar(code)!)
            } else {
                return Character.init(" ")
            }
        }
        let result = String(charArray)
        return result
    }
    
    func splitedString(string: String, length: Int) -> [String] {
        var groups = [String]()
        let regexString = "(.{1,\(length)})"
        do {
            let regex = try NSRegularExpression(pattern: regexString, options: .caseInsensitive)
            let matches = regex.matches(in: string, options: .reportCompletion, range: NSMakeRange(0, string.characters.count))
            let nsstring = string as NSString
            matches.forEach {
                let group = nsstring.substring(with: $0.range) as String
                groups.append(group)
            }
        } catch let error as NSError {
            print("Bad Regex Format = \(error)")
        }
        
        return groups
    }
}

class EncryptionManager : NSObject {

    var appDelegate: AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    func preparedPassword() -> String {
        let passPhrase: String = "secret0key007008"
        var result = String()
        
        let count = self.appDelegate.dbPassword.characters.count
        for char in self.appDelegate.dbPassword.characters {
            result.append(char)
        }
        
        for char in passPhrase.substring(from: count).characters {
            result.append(char)
        }
        
        return result
    }
    
    func encrypt(_ text: String) -> String {
        do {
            var encryptor = try AES(key: self.preparedPassword(), iv: "b3ca47f7bcfffa67").makeEncryptor()
            
            var ciphertext = Array<UInt8>()
            // aggregate partial results
            ciphertext += try encryptor.update(withBytes: Array(text.utf8))
            // finish at the end
            ciphertext += try encryptor.finish()
            
            return ciphertext.toHexString()
        } catch {
            print(error)
        }
        
        return ""
    }
    
    func decrypt(_ hexEncodedText: String) -> String {
        do {
            var decryptor = try AES(key: self.preparedPassword(), iv: "b3ca47f7bcfffa67").makeDecryptor()

            var ciphertext = Array<UInt8>()
            // aggregate partial results
            ciphertext += try decryptor.update(withBytes: hexEncodedText.arrayFromHexadecimalString())
            // finish at the end
            ciphertext += try decryptor.finish()

            return ciphertext.toRawString()
        } catch {
            print(error)
        }
        
        return ""
    }
}
