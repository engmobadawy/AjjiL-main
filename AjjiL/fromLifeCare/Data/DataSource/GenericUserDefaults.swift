//
// GenericUserDefaults.swift
//  LifeCare
//
//
//  Created by AMNY on 07/04/2025.

import Foundation
import UIKit

protocol GenericUserDefaultsProtocol {
    func getValue(_ key: String) -> Any?

    func setValue(_ value: Any?, _ key: String)

    func removeValue(_ key: String)

    func removeAllUserDefaults()

    func setObject<T>(_ key: String, _ value: T?) where T : Encodable

    func getObject<T: Codable>(_ key: String, result: T.Type) -> T?

}

class GenericUserDefault: GenericUserDefaultsProtocol {
    static var shared = GenericUserDefault()

    func getValue(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }

    func setValue(_ value: Any?, _ key: String) {
        UserDefaults.init().set(value, forKey: key)
    }

    func removeValue(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    func removeAllUserDefaults() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }

    func removeArrayOfKeys(keys: [String]) {
        for remove in keys {
            GenericUserDefault.shared.removeValue(remove)
        }
    }


    //save all object in user defaults
    func setObject<T>(_ key: String, _ value: T?) where T : Encodable {
        if value == nil {
            UserDefaults.standard.set(nil, forKey: key)
        } else {
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(value!)
            let json = String(data: jsonData!, encoding: String.Encoding.utf8)
            UserDefaults.standard.set(json, forKey: key)
        }
    }

    //save get object in user defaults
    func getObject<T>(_ key: String, result: T.Type) -> T? where T : Decodable {
        guard let jsonString = UserDefaults.standard.string(forKey: key),
              let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(result, from: jsonData)
        } catch {
            print("Decoding error: \(error)")
            return nil
        }
    }

}

