//
//  UserServiceManager.m
//  okjux
//
//  Created by TopTier labs on 11/18/16.
//
//

#import "UserServiceManager.h"
#import "DataManager.h"
#import "Snap.h"

@implementation UserServiceManager

+ (void)registerUserWith:(NSString *)uuid {
  if (![[NSUserDefaults standardUserDefaults] objectForKey:@"okjuxUserID"]) {
    NSDictionary *params = @{ @"user" : @{ @"user_uuid" : uuid} };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
      [[CommunicationManager sharedManager] sendPostRequestWithURL: [NSString stringWithFormat:@"%@users", [CommunicationManager serverURL]]
                                                         AndParams: params
                                                      AndMediaType: nil
                                                           Success: ^(id response) {
                                                               [[DataManager getInstance] storeUser: response[@"user"][@"id"]];
                                                           }
                                                           Failure: ^(id failure){
                                                             //TODO
                                                           }];
    });
  }
}

+ (void)getUserSnaps:(NSString *)uuid Onsuccess:(void(^)(NSArray* responseObject ))success Onfailure :(void(^)(NSError* error))failure {
    NSDictionary *params = @{ @"user" : @{ @"user_uuid" : uuid} };
    NSString *userId = [[DataManager getInstance] userID];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[CommunicationManager sharedManager] sendGetRequestWithURL: [NSString stringWithFormat:@"%@users/%@/snaps", [CommunicationManager serverURL], userId]
                                                          AndParams: params
                                                            Success: ^(id response) {
                                                                NSArray *snaps = [Snap parseSnapsFromAPIData: response];
                                                                success(snaps);
                                                            }
                                                            Failure: failure];
    });
}

@end
