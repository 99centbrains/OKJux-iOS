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
    aSnap.imageUrl = [snap[@"image_url"] stringValue];
    aSnap.thumbnailUrl = [snap[@"thumb_url"] stringValue];
    aSnap.netlikes = [snap[@"snap_likes"] integerValue];
    aSnap.flagged = [snap[@"is_flagged"] boolValue];
    aSnap.hidden = [snap[@"is_hidden"] boolValue];
    aSnap.userID = [snap[@"user_id"] stringValue];

    //Parse likes and dislikes
    NSMutableArray *likesArray = [NSMutableArray array];
    for (NSString *like in snap[@"likes_array"]){
        [likesArray addObject:like];
    }
    aSnap.likes = likesArray;

    NSMutableArray *dislikesArray = [NSMutableArray array];
    for (NSString *dislike in snap[@"dislikes_array"]){
        [dislikesArray addObject:dislike];
    }
    aSnap.dislikes = dislikesArray;

    //Parse flaggers
    NSMutableArray *flaggersArray = [NSMutableArray array];
    for (NSString *flagger in snap[@"flaggers_array"]){
        [flaggersArray addObject:flagger];
    }
    aSnap.flaggers = flaggersArray;
}

@end
