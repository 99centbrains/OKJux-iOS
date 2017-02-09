//
//  UserHelper.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation
import UIKit

class UserHelper {

    class func getUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }

}
