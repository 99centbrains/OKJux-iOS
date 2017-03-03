//
//  Snap.m
//  okjux
//
//  Created by Camila Moscatelli on 11/21/16.
//
//

#import "Snap.h"

@implementation Snap

- (instancetype)init {
    self = [super init];
    return self;
}


+ (NSArray *)parseSnapsFromAPIData:(NSDictionary *)data {
    NSMutableArray *snapsToReturn = [NSMutableArray array];
    for (NSDictionary* snap in data[@"snaps"]){
        Snap *aSnap = [Snap new];
        [self initializeSnap:aSnap withCommonData:snap];
        [snapsToReturn addObject:aSnap];
    }

    NSArray *returnData = [snapsToReturn copy];
    return returnData;
}

+ (void) initializeSnap:(Snap*)aSnap withCommonData:(NSDictionary *)snap {
    aSnap.ID = [snap[@"id"] integerValue];
    aSnap.hidden = [snap[@"hidden"] boolValue];
    aSnap.userID = [snap[@"user"][@"id"] integerValue];
    aSnap.netlikes = snap[@"likes_count"] == nil ? 0 : [snap[@"likes_count"] integerValue];
  
    #if LOCALHOST
    aSnap.imageUrl = [NSString stringWithFormat:@"%@%@", @"http://192.168.1.125:3000", snap[@"image"][@"image"][@"url"]];
    aSnap.thumbnailUrl = [NSString stringWithFormat:@"%@%@", @"http://192.168.1.125:3000", snap[@"image"][@"image"][@"thumbnail"][@"url"]];
    #else
    aSnap.imageUrl = snap[@"image"][@"image"][@"url"];
    aSnap.thumbnailUrl = snap[@"image"][@"image"][@"thumbnail"][@"url"];
    #endif
  
    aSnap.noAction = snap[@"liked"] == nil;
    aSnap.isLiked = snap[@"liked"] == nil ? NO : [snap[@"liked"] boolValue];
    aSnap.reported = [snap[@"reported"] boolValue];
    aSnap.flagsCount = [snap[@"flags_count"] integerValue];

    if (snap[@"created_at"] != nil) {
        aSnap.createdAt = snap[@"created_at"];
    }

    //Parse location
    NSMutableArray *locationArray = [NSMutableArray array];
    for (NSString *coord in snap[@"location"]){
        [locationArray addObject:coord];
    }
    aSnap.location = locationArray;
}

- (NSString*)description {
    return [[NSString alloc] initWithFormat:@"%li", (long)self.ID];
}

- (BOOL)isEqual:(Snap*)object {
    if (object.ID == self.ID) {
        return YES;
    }
    return NO;
}

@end
