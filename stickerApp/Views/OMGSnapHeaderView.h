//
//  OMGSnapHeaderView.h
//  okjux
//
//  Created by German Pereyra on 3/2/17.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OMGHeadSpaceViewController.h"
#import "OMGSnapsViewController.h"

@interface OMGSnapHeaderView <OMGHeadSpaceViewControllerDelegate> : UIView
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, weak) OMGSnapsViewController *parent;

- (void)showLocationPicker;
- (void)hideLocationPicker;

@end
