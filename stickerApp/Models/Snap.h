//
//  Snap.h
//  okjux
//
//  Created by Camila Moscatelli on 11/21/16.
//
//

@interface Snap : NSObject

@property (assign, nonatomic) NSInteger ID;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSString *thumbnailUrl;
@property (strong, nonatomic) NSArray *location;
@property (assign, nonatomic) NSInteger netlikes;
@property (assign, nonatomic) NSInteger flagged;
@property (assign, nonatomic) bool hidden;
@property (assign, nonatomic) bool noAction;
@property (assign, nonatomic) bool isLiked;
@property (assign, nonatomic) NSInteger userID;
@property (strong, nonatomic) NSString *createdAt;


+ (NSArray *)parseSnapsFromAPIData:(NSDictionary *)data;

@end

