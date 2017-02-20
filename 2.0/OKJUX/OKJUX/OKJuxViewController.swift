//
//  OKJuxViewController.swift
//  OKJUX
//
//  Created by German Pereyra on 20/Feb/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit
import TAOverlay
import Rswift

class OKJuxViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    func showGenericErrorMessage(error: NSError?) {
        if ConfigurationManager.environment == .development {
            print("ERROR: -> \(error?.localizedDescription)")
        }
        //TODO: show error message
    }

    func showLoading(localizedMessage: String? = R.string.localizable.loading()) {
        TAOverlay.show(withLabel: localizedMessage , options: [.overlaySizeBar, .overlayTypeActivityDefault ])
    }

    func hideLoading() {
        TAOverlay.hide()
    }
}
