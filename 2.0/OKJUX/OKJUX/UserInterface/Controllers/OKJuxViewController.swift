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

class OKJuxViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    func showGenericErrorMessage(error: NSError?) {
        if ConfigurationManager.environment == .development {
            print("ERROR: -> \(error?.localizedDescription)")
        }

        var errorTitle = R.string.localizable.error_generic_title()
        var errorMessage = R.string.localizable.error_while_getting_the_snaps()
        let errorIcon = UIImage.init(icon:.FAExclamationCircle, size: CGSize(width: 35, height: 35), textColor: .white, backgroundColor: .clear)

        if let error = error, error.code == OKJuxError.ErrorType.noInternet.rawValue {
            errorTitle = R.string.localizable.error_not_internet_title()
            errorMessage = R.string.localizable.error_not_internet_description()
        }

        let view = MessageView.viewFromNib(layout: .CardView)
        view.button?.isHidden = true
        view.configureTheme(.warning)
        view.backgroundView.backgroundColor = UIColor(red: 249.0/255.0, green: 66.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        view.configureDropShadow()
        view.configureContent(title: errorTitle, body: errorMessage, iconImage: errorIcon)
        SwiftMessages.show(view: view)
    }

    func showLoading(localizedMessage: String? = R.string.localizable.loading()) {
        TAOverlay.show(withLabel: localizedMessage, options: [.overlaySizeBar, .overlayTypeActivityDefault ])
    }

    func hideLoading() {
        TAOverlay.hide()
    }

}
