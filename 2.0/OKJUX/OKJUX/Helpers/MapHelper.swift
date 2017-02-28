//
//  MapHelper.swift
//  OKJUX
//
//  Created by German Pereyra on 2/24/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation
import MapKit

class MapHelper {

    // MARK: - Constants
//    #define kMinDistance 50
//    #define kMaxDistance 100 /// in Miles
//    #define metersInMile 1609.34

    static let metersInMile: Double = 1609.34
    static let desireMiles: Double = 50

    static let location = CLLocationCoordinate2D(
        latitude: -34.907000,
        longitude: -56.190005
    )

    // MARK: - Zoom methods

    class func zoomToFitMapAnnotations(mapView map: MKMapView, maxDistanceMiles miles: Double = 5) {
        guard !map.annotations.isEmpty else {
            return
        }
        let memberlocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in map.annotations {

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
            zoomToRegion(mapView: map)
            return
        }
        region = map.regionThatFits(region)
        map.setRegion(region, animated: true)
    }

    class func zoomToRegion(mapView map: MKMapView) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }

    class func distanceInMettersBetween(location1: (Double, Double), location2: (Double, Double)) -> Double {
        let loc1 = CLLocation(latitude: location1.0, longitude: location1.1)
        let loc2 = CLLocation(latitude: location2.0, longitude: location2.1)
        return loc1.distance(from: loc2)
    }

    class func loadMapWithNearbySnaps(mapView map: MKMapView) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        map.isUserInteractionEnabled = false
        map.addSubview(activityIndicator)
        activityIndicator.center = map.center
        activityIndicator.startAnimating()

        SnapsManager.sharedInstance.getSnaps(hottest: false,
                                             page: 1,
                                             latitude: location.latitude,
                                             longitude: location.longitude,
                                             radius: metersInMile * metersInMile) { (error, snapsResult) in
            activityIndicator.stopAnimating()
            if error == nil {
                if let snapsResult = snapsResult, !snapsResult.isEmpty {
                    self.reloadMap(MapView: map, snaps: snapsResult)
                    return
                }
            }
        }
    }

    class func reloadMap(MapView map: MKMapView, snaps: [Snap]) {
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
