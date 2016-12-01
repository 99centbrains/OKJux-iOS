//
//  GeneralHelper.m
//  okjux
//
//  Created by Camila Moscatelli on 12/1/16.
//
//

#import "GeneralHelper.h"

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

@end
