//
//  SnapsPageViewController.swift
//  OKJUX
//
//  Created by German Pereyra on 2/22/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit

class SnapsPageViewController: UIViewController {

    // MARK: - Data Variables

    var orderedViewControllers: [UIViewController]!
    weak var currentPresentedViewController: UIViewController?

    // MARK: - UI Variables

    var pageViewController: UIPageViewController!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false

        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        if let firstViewController = orderedViewControllers[0] as UIViewController? {
            pageViewController.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            currentPresentedViewController = firstViewController
        }

        pageViewController.dataSource = self
        pageViewController.delegate = self

        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pageViewController.view.anchorToEdge(.top, padding: 0, width: self.view.width, height: self.view.height)
    }

}

// MARK: - UIPageViewControllerDataSource

extension SnapsPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {

        guard let newPresentingController = pendingViewControllers.first else {
            return
        }
        self.currentPresentedViewController = newPresentingController
        if let _ = self.orderedViewControllers.index(of: newPresentingController) {
            //TODO: mark the segmented option as selected
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 && orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex && orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }

}
