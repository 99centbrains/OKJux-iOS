//
//  GeneralHelper.h
//  okjux
//
//  Created by Camila Moscatelli on 12/1/16.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface GeneralHelper : NSObject

#pragma mark Convertions

+ (NSDate*)convertToLocalTimeZone:(NSString*)serverDate;

#pragma mark Permissions

+ (BOOL)haveCameraAuthorization;

+ (BOOL)havePhotoLibraryAuthorization;

@end
