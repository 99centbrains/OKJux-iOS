//
//  DataHolder.h
//  YikYak
//
//  Created by PCC on 16/11/2014.
//  Copyright (c) 2014 Kanwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface DataHolder : NSObject{

    PFUser *currentUser;
    

    
}
@property(nonatomic,strong) PFUser *userObject;
@property(nonatomic,strong) NSArray *arrayTopSnaps;
@property(nonatomic,strong) NSArray *arrayMySnaps;
@property(nonatomic,strong) NSArray *arrayNewestSnaps;

@property (nonatomic, strong) PFGeoPoint * userGeoPoint;

+ (DataHolder *) DataHolderSharedInstance;

- (NSInteger) checkUserLikeStatus:(PFObject *)selectedSnap;

-(void)saveMyPeeks;

@end
