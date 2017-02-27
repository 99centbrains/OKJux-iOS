//
//  LandingViewController.swift
//  OKJUX
//
//  Created by German Pereyra on 2/23/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit
import MapKit

class LandingViewController: OKJuxViewController {

    // MARK: - Constants

    static let landingScreenMapHeight: CGFloat = 120
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
    var segment: UIView!

    // MARK: - Data variables

    var isMapExpanded: Bool = false

    // MARK: - Controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSnapsPager()
        setUpMap()
        setUpSegment()
    }

    // MARK: - Layout methods

    func setUpSnapsPager() {

        let pagedSnapsViewController = SnapsPageViewController()
        let newestSnaps = SnapsViewController()
        let hottestSnaps = SnapsViewController(hottest: true)
        newestSnaps.delegate = self
        hottestSnaps.delegate = self
        pagedSnapsViewController.orderedViewControllers = [newestSnaps, hottestSnaps]

        snapsPagedView = pagedSnapsViewController.view
        addChildViewController(pagedSnapsViewController)
        view.addSubview(snapsPagedView)
        pagedSnapsViewController.didMove(toParentViewController: self)
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
        segment = UIView(frame: CGRect(x: 0, y: mapHeigth, width: view.width, height: segmentHeight))
        view.addSubview(segment)
        segment.backgroundColor = .yellow
    }

    // MARK: Util methods

    func expandMap() {
        map.isUserInteractionEnabled = true
        isMapExpanded = true
        segment.isHidden = true
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

extension LandingViewController: SnapsViewControllerDelegate {

    func snapsViewController(_ snapsViewController: SnapsViewController, isExpandingToPosition position: CGFloat) {
        if !isMapExpanded {
            if position >= 0 {
                //Resize map
                map.change(height: mapHeigth + position)
            }
            //Move segment
            if mapHeigth + position >= 0 {
                segment.change(originY: mapHeigth + position)
            } else {
                segment.change(originY: 0)
            }
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
