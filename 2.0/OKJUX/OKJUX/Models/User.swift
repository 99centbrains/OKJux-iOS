//
//  User.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation
import UIKit

class User {

    var id : Double!
    var uuid: String!
    var karma: Int!


    init(id: Double, uuid: String, karma: Int) {
        self.id = id
        self.uuid = uuid
        self.karma = karma
    }

}
