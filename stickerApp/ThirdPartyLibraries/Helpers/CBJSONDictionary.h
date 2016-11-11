//
//  CBAppConfig.h
//  ShellSticker
//
//  Created by Philip Ybay on 5/8/14.
//  Copyright (c) 2014 99centbrains. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface CBJSONDictionary : NSDictionary

+ (CBJSONDictionary *) shared;

@property (nonatomic, strong) NSString *jsonURL;
@property (nonatomic, strong) NSURL *CBAssetsURL;
@property (nonatomic, strong) NSArray *array_bundles;

- (void)getJSON:(NSString *)url;

//IAP
- (NSArray *) getAllPackIDs;


//BUNDLES
- (NSDictionary *) getBundleNameID;
- (NSArray *) getBundleIDs;
- (void) getBundleHeroImageFromID:(NSString *)bundleID withReturn:(void (^)(NSURL * heroURL))callback;

//PACKS
- (NSDictionary *) getPackFromBundleID:(NSString *)bundleID byPackID:(NSString*)packID;
- (NSArray *) getPackIDs:(NSString *)bundleID;
- (NSArray *) getPacksFromBundleID:(NSString *)bundleID;

- (NSDictionary *) getSocialLinksFromPackID:(NSString *)bundleID byPackID:(NSString*)packID;

//TODO this method is not implemented
- (void) getStickersFromBundle:(NSString *)bundleID byPackID:(NSString *)packID complete:(void (^)(NSArray *))callback;

//DIRECTORIES
- (NSString *) pathForAssetsDirectory;

- (NSArray *) getPackForPackID:(NSDictionary *)pack withID:(NSString *)packID byBundleID:(NSString *)bundleID;
- (NSArray *) pathForPackDIR:(NSString *)packDIR byBundleID:(NSString *)bundleID;


- (void) addItemsToPlist:(NSArray *)items withID:(NSString *)packID;
- (void) writeImageData:(NSData *)imgData toDirectory:(NSString *)directory;
- (void) writeStickersPack:(NSDictionary *)pack fromBundle:(NSString *)bundleID withSticker:(NSArray *)items;


//STORING IMAGES
- (void) saveLastCatwangImage:(UIImage *)image;
    - (UIImage *) lastCatwangImage;

#pragma PARSE Stuff
- (void) parse_trackAnalytic:(NSDictionary *)data forEvent:(NSString *)event;

@end
