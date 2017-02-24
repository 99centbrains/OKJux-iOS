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
    let location = CLLocationCoordinate2D(
        latitude: -34.907000,
        longitude: -56.190005
    )

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
        view.insertSubview(map, at: 0)

        zoomToRegion()

    }

    // MARK: - Map methods

    func zoomToRegion() {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
        map.delegate = self
    }

    func zoomToFitMapAnnotations(aMapView: MKMapView, maxDistanceMiles miles: Double = 5) {
        guard !aMapView.annotations.isEmpty else {
            return
        }
        let memberlocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in aMapView.annotations {

            let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            let distance = memberlocation.distance(from: annotationLocation)
            if distance <= 1609 * miles {
                // under 1 mile
                topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
                topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
            }
        }

        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        if region.center.latitude == 0 || region.center.longitude == 0 {
            zoomToRegion()
            return
        }
        region = aMapView.regionThatFits(region)
        aMapView.setRegion(region, animated: true)
    }

    func reloadMap(snaps: [Snap]) {
        map.removeAnnotations(map.annotations)
        for snap in snaps {
            let location = CLLocationCoordinate2D(
                latitude: snap.location.0,
                longitude: snap.location.1
            )
            let annotation = SnapAnnotation(coordinate: location, snap: snap)
            map.addAnnotation(annotation)
        }
    }

}

import MapKit

class SnapAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var snap: Snap!

    init(coordinate: CLLocationCoordinate2D, snap: Snap) {
        self.coordinate = coordinate
        self.snap = snap
    }
}

class SnapAnnotationView: MKAnnotationView {

    static let reuseIdentifier: String = "SnapAnnotationView"
    let contentInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    var snapImage: UIImageView!

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        snapImage = UIImageView(frame: CGRect.zero)
        snapImage.clipsToBounds = true
        snapImage.contentMode = .scaleAspectFill
        addSubview(snapImage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        snapImage.frame = CGRect(x: contentInset.left,
                                 y: contentInset.top,
                                 width: bounds.width - contentInset.left - contentInset.right,
                                 height: bounds.height - contentInset.top - contentInset.bottom)
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
        annotationView?.image = R.image.snap_heart_like()
        return annotationView
    }
}

extension LandingViewController: SnapsViewControllerDelegate {

    func snapsViewController(_ snapsViewController: SnapsViewController, hasBeenExpandedToPosition position: CGFloat) {
        if position > 50 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.snapsPagedView.change(originY: self.view.height - self.expandedBottomMargin)
            }, completion: nil)
        }
    }

    func snapsViewController(_ snapsViewController: SnapsViewController, updatedSnapsList snaps: [Snap]) {
        reloadMap(snaps: snaps)
        zoomToFitMapAnnotations(aMapView: map)
    }
}
