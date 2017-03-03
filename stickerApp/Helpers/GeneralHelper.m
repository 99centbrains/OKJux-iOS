//
//  GeneralHelper.m
//  okjux
//
//  Created by Camila Moscatelli on 12/1/16.
//
//

#import "GeneralHelper.h"
#import "NSDate+DateTools.h"
#import <CoreLocation/CoreLocation.h>

@implementation GeneralHelper

#pragma mark Convertions

+ (NSDate*)convertToLocalTimeZone:(NSString*)serverDate {
    NSDateFormatter *serverFormatter = [[NSDateFormatter alloc] init];
    [serverFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

    [serverFormatter setDateFormat:SERVER_FORMAT];

    return [serverFormatter dateFromString:serverDate];
}

#pragma mark Permissions

+ (BOOL)haveCameraAuthorization {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    return authStatus == AVAuthorizationStatusAuthorized;
}

+ (BOOL)havePhotoLibraryAuthorization {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    return status == PHAuthorizationStatusAuthorized;
}

+ (NSString*)getTimeAgoFromString:(NSString*)createdAt {
    NSDate *createdDate = [GeneralHelper convertToLocalTimeZone:createdAt];
    NSDate *nowDate = [NSDate date];
    NSTimeInterval timerPeriod = [nowDate timeIntervalSinceDate:createdDate];
    NSDate *timeAgoDate = [NSDate dateWithTimeIntervalSinceNow:timerPeriod];

    NSString *timeString = [@"🕑 " stringByAppendingString:timeAgoDate.timeAgoSinceNow];
    return timeString;
}

+ (void)reverseGeoLocation:(double)lat lng:(double)lng completionHandler:(void (^)(NSString*))completion {
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];

    [reverseGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"reverseGeocoder ERROR %f, %f", lat, lng);
            return;
        }
        CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
        NSString *country = myPlacemark.country;
        NSString *city = myPlacemark.locality;
        if (city != nil && country != nil) {
            NSString *locationString = [NSString stringWithFormat:@" 📍 %@ - %@", country, city];
            completion(locationString);
        }
    }];
}

@end
