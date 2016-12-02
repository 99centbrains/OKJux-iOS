//
//  OMGMapAnnotation.h
//  catwang
//
//  Created by Fonky on 2/22/15.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Snap.h"


@interface OMGMapAnnotation : NSObject <MKAnnotation> {
    
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (nonatomic, strong) UIImage *thumbnail;

@property (nonatomic, strong) Snap *snap;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location andTitle:(NSString *)title andThumbNail:(UIImage*)thumb;

- (MKAnnotationView *)annotationView;

@end

