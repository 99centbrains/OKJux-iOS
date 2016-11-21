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
@property (strong, nonatomic) NSArray *likes;
@property (strong, nonatomic) NSArray *dislikes;
@property (strong, nonatomic) NSArray *flaggers;
@property (assign, nonatomic) NSInteger netlikes;
@property (assign, nonatomic) bool flagged;
@property (assign, nonatomic) bool hidden;
@property (strong, nonatomic) NSString *userID;


+ (NSArray *)parseSnapsFromAPIData:(NSDictionary *)data;

@end

