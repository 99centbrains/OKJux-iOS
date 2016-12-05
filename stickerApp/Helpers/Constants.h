//
//  Constants.h
//  PixelFace
//
//  Created by Franky Aguilar on 2/25/13.
//
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#ifndef OKJUX_Constants_h
#define OKJUX_Constants_h

//DEBUG
#define kStickerDebug NO
#define kJsonDebug NO
#define kAdminDebug NO

//IMAGES
#define ImageMimeType @"image/png"
#define ImageExtension @"png"

//NSUSERDEFAULSKEYS
#define kNewUserKey @"kUserDefaultUserNew"
#define kUserBanStatus @"kUserDefaultBanStatus"
#define kNewUserMakeSomething @"kUserDefaultMakeSomething"

//SDK Keys
#define kFlurryKey @"BJ2X2Q33PNF2YMBVV8W8"
#define kApplicationProductName @"okjux"
#define kAppiTunesID 511664488

#define kSocialFacebook @"http://facebook.com/99centbrains"
#define kSocialTwitter @"http://twitter.com/99centbrains"
#define kSocialInstagram @"http://instagram.com/99centbrains"
#define kSocialWeb @"http://99centbrains.com"

//App URLs
#define kPlistURL @"http://www.okjux.com/plists/41bde25a8b4d63beb14b74ba67229fce.plist"
#define kJSONScheme @"http://www.okjux.com/assets/okjux_schema.json"
#define kiTunesAPPURL @"https://itunes.apple.com/app/id511664488"


//Photo Lib Album Name
#define kAlbumName @"okjux"

//SHARING
#define kShareDescription @"#okjux"
#define kShareURL @"http://okjux.com"
#define kInstagramParam @"#okjux"


//PARSE POINT SYSTEM
#define kParseLikingPoints 1
#define kParseLikedPoints 1

#define kParsePostSnap 2

//DISCOVER
#define kMinDistance 50
#define kMaxDistance 100 /// in Miles
#define metersInMile 1609.34

#pragma mark Dates
static NSString* const SERVER_FORMAT = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

//MAP
#define METERS_PER_MILE 16093.4

#pragma mark Pagination
static NSInteger const SNAP_PER_PAGE = 40;

#endif
