//
//  ConfigurationManager.swift
//  Unshakeable
//
//  Created by Martin Zuniga NR on 11/24/16.
//  Copyright © 2016 Tony Robbins. All rights reserved.
//

import Foundation

class ConfigurationManager: NSObject {

    enum Environment: String {
        case development = "Debug"
        case beta = "Beta"
        case staging = "Staging"
        case production = "Release"
    }

    static let sharedInstance = ConfigurationManager()

    var configs: [String: String]!

    static let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "Configuration")!

    override init() {

        if let url = Bundle.main.url(forResource: "Configuration-\(ConfigurationManager.currentConfiguration)", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                configs = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: String]
            } catch {
                print(error)
            }
        }
    }

}
