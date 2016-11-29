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


@end
