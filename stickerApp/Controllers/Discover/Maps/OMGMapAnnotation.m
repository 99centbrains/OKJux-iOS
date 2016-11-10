//
//  OMGMapAnnotation.m
//  catwang
//
//  Created by Fonky on 2/22/15.
//
//

#import "OMGMapAnnotation.h"
#import <MapKit/MapKit.h>

@implementation OMGMapAnnotation


- (id)initWithCoordinates:(CLLocationCoordinate2D)location andTitle:(NSString *)title andThumbNail:(UIImage*)thumb {
    self = [super init];
    
    if (self) {
        _title = title;
        _thumbnail = [self imageWithImage:thumb scaledToSize:CGSizeMake(58, 58)];
        _coordinate = location;
    }
    
    return self;
}

- (MKAnnotationView *) annotationView {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"com.anno"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.clipsToBounds = NO;
    annotationView.image = _thumbnail;
    annotationView.layer.shadowOffset = CGSizeMake(0, 0);
    annotationView.layer.shadowRadius = 5;
    annotationView.layer.shadowOpacity = 0.5;
    
    return annotationView;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    //STROKE
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //Set stroking color and draw circle
    [[UIColor whiteColor] setFill];
    //Make circle rect 5 px from border
    CGRect circleRect = CGRectMake(0, 0, newSize.width, newSize.width);
    //Draw circle
    CGContextFillEllipseInRect(ctx, circleRect);
    CGRect paddRect = CGRectMake(4, 4, newSize.width - 8, newSize.height - 8);
    [[UIBezierPath bezierPathWithRoundedRect:paddRect
                                cornerRadius:newSize.width-8/2] addClip];
    [image drawInRect:CGRectMake(4, 4, newSize.width - 8, (image.size.height/image.size.width * newSize.width) - 8)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

@end
