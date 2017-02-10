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

    var id : Int!
    var uuid: String?
    var karma: Int!


    init?(id: Int?, uuid: String?, karma: Int?) {
        guard let id = id, let uuid = uuid, let karma = karma else {
            return nil
        }
        self.id = id
        self.uuid = uuid
        self.karma = karma
    }

    convenience init?(json: [String: Any]?) {
        guard let json = json else {
            return nil
        }
        self.init(id: json["id"] as? Int, uuid: json["UUID"] as? String, karma: json["karma"] as? Int)
    }

}
