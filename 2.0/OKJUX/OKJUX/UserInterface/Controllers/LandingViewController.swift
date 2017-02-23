//
//  LandingViewController.swift
//  OKJUX
//
//  Created by German Pereyra on 2/23/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit

class LandingViewController: OKJuxViewController {

    // MARK: - Constants

    let mapHeigth: CGFloat = 120
    let expandedBottomMargin: CGFloat = 15

    // MARK: - UI variables

    var snapsPagedView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let pagedSnapsViewController = SnapsPageViewController()
        let newestSnaps = SnapsViewController()
        let hottestSnaps = SnapsViewController(hottest: true)
        newestSnaps.expandableDelegate = self
        
        hottestSnaps.expandableDelegate = self
        pagedSnapsViewController.orderedViewControllers = [newestSnaps, hottestSnaps]

        snapsPagedView = pagedSnapsViewController.view
        snapsPagedView.change(height: view.height - mapHeigth)
        snapsPagedView.change(originY: mapHeigth)
        addChildViewController(pagedSnapsViewController)
        view.addSubview(snapsPagedView)
        pagedSnapsViewController.didMove(toParentViewController: self)
    }

}

extension LandingViewController: SnapsViewControllerScrollDelegate {

    func snapsViewController(_ snapsViewController: SnapsViewController, hasBeenExpandedToSizeHeight height: CGFloat) {
        if height > 50 {
            UIView.animate(withDuration: 0.3) {
                self.snapsPagedView.change(originY: self.view.height - self.expandedBottomMargin - self.mapHeigth)
            }
        }
    }
}
