//
//  OMGMapViewController.h
//  catwang
//
//  Created by Fonky on 2/16/15.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OkJuxViewController.h"

@class OMGMapViewController;

@protocol OMGMapViewControllerDelegate <NSObject>

- (void) omgMapViewNewCoordinate:(CLLocationCoordinate2D)CLCoord;

@end


@interface OMGMapViewController : OkJuxViewController


//INIT MAP
@property (nonatomic, assign) BOOL newLocation;

@property (nonatomic, unsafe_unretained) id <OMGMapViewControllerDelegate> delegate;


@end
