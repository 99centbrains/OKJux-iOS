//
//  SnapServiceManager.h
//  okjux
//
//  Created by Camila Moscatelli on 11/23/16.
//
//

#import <Foundation/Foundation.h>
#import "CommunicationManager.h"
#import "DataManager.h"
#import "Snap.h"

@interface SnapServiceManager : NSObject

+ (void)getSnaps:(NSDictionary *)params OnSuccess:(void(^)(NSArray* responseObject ))success OnFailure :(void(^)(NSError* error))failure;

+ (void)rankSnap:(NSInteger)snapID withLike:(BOOL)like OnSuccess:(void(^)(NSDictionary* responseObject ))success OnFailure :(void(^)(NSError* error))failure;

+ (void)getSnapsNearBy:(NSDictionary *)params OnSuccess:(void(^)(NSArray* responseObject ))success OnFailure :(void(^)(NSError* error))failure;

+ (void)reportSnap:(NSInteger)snapID OnSuccess:(void(^)(NSDictionary* responseObject ))success OnFailure :(void(^)(NSError* error))failure;

@end
