//
//  LandingViewController.swift
//  OKJUX
//
//  Created by German Pereyra on 2/23/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit
import MapKit
import Neon

class LandingViewController: OKJuxViewController {

    // MARK: - Constants

    static let landingScreenMapHeight: CGFloat = 160
    static let landingScreenSegmentHeight: CGFloat = 40

    fileprivate var mapHeigth: CGFloat {
        return type(of: self).landingScreenMapHeight
    }
    fileprivate var segmentHeight: CGFloat {
        return type(of: self).landingScreenSegmentHeight
    }
    fileprivate let expandedBottomMargin: CGFloat = 15
    fileprivate let expandTriggerPosition: CGFloat = 100

    // MARK: - UI variables

    var snapsPagedView: UIView!
    var map: MKMapView!
    var segmentContainer: UIView!
    var segment: UISegmentedControl!
    var snapsPageViewController: SnapsPageViewController!

    // MARK: - Data variables

    var isMapExpanded: Bool = false

    // MARK: - Controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSnapsPager()
        setUpMap()
        setUpSegment()
        setUpNavigation()
    }

    // MARK: - Layout methods

    func setUpSnapsPager() {

        snapsPageViewController = SnapsPageViewController()
        snapsPageViewController.delegate = self
        let newestSnaps = SnapsViewController()
        let hottestSnaps = SnapsViewController(hottest: true)
        newestSnaps.delegate = self
        hottestSnaps.delegate = self
        snapsPageViewController.orderedViewControllers = [newestSnaps, hottestSnaps]

        snapsPagedView = snapsPageViewController.view
        addChildViewController(snapsPageViewController)
        view.addSubview(snapsPagedView)
        snapsPageViewController.didMove(toParentViewController: self)
    }

    func setUpMap() {
        map = MKMapView(frame: CGRect(x: 0, y: 0, width: view.width, height: mapHeigth))
        map.accessibilityLabel = "Snaps map"
        map.accessibilityValue = "collapsed"
        map.showsUserLocation = true
        view.insertSubview(map, at: 0)
        MapHelper.zoomToRegion(mapView: map)
        MapHelper.loadMapWithNearbySnaps(mapView: map)
        map.delegate = self
    }

    func setUpSegment() {
        segmentContainer = UIView(frame: CGRect(x: 0, y: mapHeigth, width: view.width, height: segmentHeight))
        view.addSubview(segmentContainer)
        segmentContainer.backgroundColor = .lightGray
        let items = [R.string.localizable.newest(), R.string.localizable.hottest()]
        self.segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.layer.cornerRadius = 5.0
        segment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .normal)
        segment.frame = segmentContainer.bounds
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentContainer.addSubview(segment)
    }

    func setUpNavigation() {
        self.title = R.string.localizable.landing_title()
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(-4, for: .default)
        let leftButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let karmaIcon = UIImageView(image: UIImage.init(icon: .FAAdjust, size: CGSize(width: 25, height: 25)))
        let karmaValue = UILabel()
        karmaValue.font = UIFont.systemFont(ofSize: 14)
        karmaValue.textColor = .black
        karmaValue.text = String(UserManager.sharedInstance.loggedUser?.karma ?? 0)
        karmaValue.sizeToFit()
        leftButtonView.addSubview(karmaValue)
        leftButtonView.addSubview(karmaIcon)
        karmaValue.align(.toTheRightCentered, relativeTo: karmaIcon, padding: 5, width: karmaValue.width, height: karmaValue.height)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButtonView)
    }

    // MARK: - Actions

    func segmentChanged() {
        snapsPageViewController.changeSelectedOption(segment.selectedSegmentIndex, fromOption: segment.selectedSegmentIndex == 0 ? 1 : 0)
    }

    // MARK: - Util methods

    func expandMap() {
        map.isUserInteractionEnabled = true
        isMapExpanded = true
        segmentContainer.isHidden = true
        map.accessibilityValue = "expanded"
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.map.change(height: self.view.height - self.expandedBottomMargin)
            self.map.isUserInteractionEnabled = true
            self.snapsPagedView.change(originY: self.view.height - self.expandedBottomMargin)
        }, completion: nil)
    }

    func collapseMap() {
        isMapExpanded = false
        map.accessibilityValue = "collapsed"
        map.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.map.change(height: self.mapHeigth)
            self.map.isUserInteractionEnabled = false
            self.snapsPagedView.change(originY: self.mapHeigth)
        }, completion: nil)
    }

}

// MARK: - MKMapViewDelegate

extension LandingViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? SnapAnnotation else {
            return nil
        }

        var annotationView: SnapAnnotationView? = map.dequeueReusableAnnotationView(withIdentifier: SnapAnnotationView.reuseIdentifier) as? SnapAnnotationView
        if annotationView == nil {
            annotationView = SnapAnnotationView(annotation: annotation, reuseIdentifier: SnapAnnotationView.reuseIdentifier)
            annotationView!.canShowCallout = false
        }

        annotationView?.annotation = annotation
        annotationView?.snapImage.sd_setImage(with: URL(string: annotation.snap.snapImage.thumbnailURL))
        annotationView?.image = R.image.snap_heart_like() //TODO: use the real background image
        return annotationView
    }

}

// MARK: - SnapsViewControllerDelegate

extension LandingViewController: SnapsViewControllerDelegate {

    func snapsViewController(_ snapsViewController: SnapsViewController, isExpandingToPosition position: CGFloat) {
        if !isMapExpanded {
            if position >= 0 {
                //Resize map
                map.change(height: mapHeigth + position)
            }
            //Move segment
            if mapHeigth + position >= self.navigationController?.navigationBar.height ?? 0 {
                segmentContainer.change(originY: mapHeigth + position)
            } else {
                segmentContainer.change(originY: self.navigationController?.navigationBar.height ?? 0)
            }

            let percentage = (((position * 100) / (mapHeigth - segmentHeight)) / 100) * -1
            let alpha = max(min(1, percentage), 0)
            self.navigationController?.navigationBar.backgroundColor = UIColor(white: 1, alpha: alpha)
        }
    }

    func snapsViewController(_ snapsViewController: SnapsViewController, didFinishExpandingToPosition position: CGFloat) {
        if position > expandTriggerPosition {
            expandMap()
        }
    }

    func snapsViewControllerExpandMap(_ snapsViewController: SnapsViewController, didPressOnHeader header: UIView?) {
        expandMap()
    }
}

extension LandingViewController: SnapsPageViewControllerDelegate {

    func willChangeToPage(index: Int) {
        self.segment.selectedSegmentIndex = index
    }

}
