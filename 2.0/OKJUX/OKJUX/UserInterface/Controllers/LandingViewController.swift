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

    let mapHeigth: CGFloat = 120
    let expandedBottomMargin: CGFloat = 15

    // MARK: - UI variables

    var snapsPagedView: UIView!
    var map: MKMapView!

    // MARK: - Controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSnapsPager()
        setUpMap()
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
        snapsPagedView.change(height: view.height - mapHeigth)
        snapsPagedView.change(originY: mapHeigth)
        addChildViewController(pagedSnapsViewController)
        view.addSubview(snapsPagedView)
        pagedSnapsViewController.didMove(toParentViewController: self)
    }

    func setUpMap() {
        map = MKMapView(frame: CGRect(x: 0, y: 0, width: view.width, height: mapHeigth))
        map.showsUserLocation = true
        view.insertSubview(map, at: 0)
        MapHelper.zoomToRegion(mapView: map)
        MapHelper.loadMapWithNearbySnaps(mapView: map)
        map.delegate = self
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

    func snapsViewController(_ snapsViewController: SnapsViewController, hasBeenExpandedToPosition position: CGFloat) {
        if position > 50 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.map.change(height: self.view.height - self.expandedBottomMargin)
                self.map.isUserInteractionEnabled = true
                self.snapsPagedView.change(originY: self.view.height - self.expandedBottomMargin)
            }, completion: nil)
        }
    }
}
