//
//  DataHolder.m
//  YikYak
//
//  Created by PCC on 16/11/2014.
//  Copyright (c) 2014 Kanwal. All rights reserved.
//

#import "DataHolder.h"
#import <MapKit/MapKit.h>

@implementation DataHolder

//@synthesize userObject,snapArray,featuredArray,peeksNearArray,myPeeksNames,myPeeksLocations;

static DataHolder *DataHolderSharedInstance = nil;

+ (id ) alloc {
    
    @synchronized([DataHolder class]) {
        
        NSAssert(DataHolderSharedInstance == nil, @"Attempted to allocate a second instance of a singleton.");
        DataHolderSharedInstance = [super alloc];
        return DataHolderSharedInstance;
        
    }
    return nil;
}
- (id) init {
    
    self = [super init];
    if (self != nil) {
        
//        NSDictionary *dic=[[NSUserDefaults standardUserDefaults] objectForKey:@"mypeeks"];
//        myPeeksLocations=[[NSMutableArray alloc] init];
//        myPeeksNames=[[NSMutableArray alloc] init];
//        for (NSString *str in [dic objectForKey:@"names"]) {
//            [myPeeksNames addObject:str];
//        }
//        
//        NSArray *arr=[dic objectForKey:@"locations"];
//        for (NSDictionary *dic in arr) {
//            NSNumber *lat=[dic objectForKey:@"lat"];
//            NSNumber *lng=[dic objectForKey:@"long"];
//            CLLocationCoordinate2D coord=CLLocationCoordinate2DMake([lat floatValue],[lng floatValue]);
//            [myPeeksLocations addObject:[NSValue valueWithMKCoordinate:coord]];
//        }
    }
    return self;
    
}

+ (DataHolder *) DataHolderSharedInstance {
    
    @synchronized ([DataHolder class]) {
        
        if (!DataHolderSharedInstance)
        {
            DataHolderSharedInstance = [[DataHolder alloc] init];
        }
        return DataHolderSharedInstance;
    }
    return nil;
}



- (NSInteger) checkUserLikeStatus:(PFObject *)selectedSnap{
    
    [selectedSnap fetchInBackground];
    
    NSMutableArray *likeArray= [[NSMutableArray alloc] initWithArray:selectedSnap[@"likes"]];
    
    for (NSString *userLike in likeArray) {
        
        if ([userLike isEqualToString:[DataHolder DataHolderSharedInstance].userObject.objectId]){
            
            return 1;
            
        } 
        
    }
    
    NSMutableArray *dislikesarray= [[NSMutableArray alloc] initWithArray:selectedSnap[@"dislikes"]];
    
    for (NSString *userLike in dislikesarray) {
        
        if ([userLike isEqualToString:[DataHolder DataHolderSharedInstance].userObject.objectId]){
            
            return 2;
            
        }
    }
    
    
    return 0;
    
}



@end
