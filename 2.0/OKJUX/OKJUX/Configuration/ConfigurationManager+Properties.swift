//
//  ConfigurationManager+Properties.swift
//  Unshakeable
//
//  Created by Martin Zuniga NR on 11/24/16.
//  Copyright © 2016 Tony Robbins. All rights reserved.
//

import Foundation

extension ConfigurationManager {
    
    static var environment: Environment {
        return Environment(rawValue: ConfigurationManager.currentConfiguration as! String)!
    }
    
    static var serverHost: String {
        return sharedInstance.configs["Server_Host"]!
    }

    static var serverProtocol: String {
        return sharedInstance.configs["Server_Protocol"]!
    }
    
}
