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
import SwiftMessages
import AlertHelperKit

class OKJuxViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
    }

    func showGenericErrorMessage(error: NSError?) {
        if ConfigurationManager.environment == .development {
            print("ERROR: -> \(error?.localizedDescription)")
        }

        var errorTitle = R.string.localizable.error_generic_title()
        var errorMessage = R.string.localizable.error_while_getting_the_snaps_body()

        if let error = error, error.code == OKJuxError.ErrorType.noInternet.rawValue {
            errorTitle = R.string.localizable.error_not_internet_title()
            errorMessage = R.string.localizable.error_not_internet_body()
        }
        self.showAlert(title: errorTitle, body: errorMessage, cancelButton: R.string.localizable.oK())
    }

    func showLoading(localizedMessage: String? = R.string.localizable.loading()) {
        TAOverlay.show(withLabel: localizedMessage, options: [.overlaySizeBar, .overlayTypeActivityDefault])
    }

    func hideLoading() {
        TAOverlay.hide()
    }

    func showSuccess() {
        TAOverlay.show(withLabel: R.string.localizable.done(), options: [.autoHide, .overlayTypeSuccess])
    }

    func showAlertAndWaitForResponse(title: String, body: String, cancelButton: String, otherButtons: [String]? = nil, handler: @escaping (Int) -> Void) {
        let params = Parameters(title: title, message: body, cancelButton: cancelButton, otherButtons: otherButtons)
        AlertHelperKit().showAlertWithHandler(self, parameters: params, handler: handler)
    }

    func showAlert(title: String, body: String, cancelButton: String) {
        AlertHelperKit().showAlert(self, title: title, message: body, button: cancelButton)
    }
}
