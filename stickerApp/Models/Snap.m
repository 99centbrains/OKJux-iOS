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
    aSnap.imageUrl = snap[@"image"][@"url"];
    aSnap.thumbnailUrl = snap[@"image"][@"thumbnail"][@"url"];
    aSnap.netlikes = snap[@"likes_count"] == nil ? 0 : [snap[@"likes_count"] integerValue];
    aSnap.noAction = snap[@"liked"] == nil;
    aSnap.isLiked = snap[@"liked"] == nil ? NO : [snap[@"liked"] boolValue];
    aSnap.reported = snap[@"reported"] == 0 ? NO : YES;
    aSnap.flagsCount = [snap[@"flags_count"] integerValue];

    //TODO this will change once flaggers are added to backend - Parse snap flagged
    if (snap[@"is_flagged"] == nil) {
        aSnap.flagged = 0;
    }

    //TODO this will change once created at added to backend
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

@end
