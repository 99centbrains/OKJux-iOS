//
//  UserServiceManager.h
//  okjux
//
//  Created by TopTier labs on 11/18/16.
//
//

#import <Foundation/Foundation.h>
#import "CommunicationManager.h"

@interface UserServiceManager : NSObject

+ (void)registerUserWith:(NSString*)uuid;

@end
