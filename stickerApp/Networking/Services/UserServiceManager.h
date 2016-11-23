//
//  UserServiceManager.h
//  okjux
//
//  Created by TopTier labs on 11/18/16.
//
//

#import <Foundation/Foundation.h>
#import "CommunicationManager.h"
#import "DataManager.h"
#import "Snap.h"

@interface UserServiceManager : NSObject

+ (void)registerUserWith:(NSString*)uuid;

+ (void)getUserSnaps:(NSString*)uuid Onsuccess:(void(^)(NSArray* responseObject ))success Onfailure :(void(^)(NSError* error))failure;

+ (void)createSnap:(NSDictionary *)params Onsuccess:(void(^)(NSDictionary* responseObject))success Onfailure :(void(^)(NSError* error))failure;

@end
