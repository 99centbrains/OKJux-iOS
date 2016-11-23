//
//  UserServiceManager.m
//  okjux
//
//  Created by TopTier labs on 11/18/16.
//
//

#import "UserServiceManager.h"

@implementation UserServiceManager

+ (void)registerUserWith:(NSString *)uuid {
  if (![[NSUserDefaults standardUserDefaults] objectForKey:@"okjuxUserID"] != nil) {
    NSDictionary *params = @{ @"user" : @{ @"UUID" : uuid} };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
      [[CommunicationManager sharedManager] sendPostRequestWithURL: [NSString stringWithFormat:@"%@users", [CommunicationManager serverURL]]
                                                         AndParams: params
                                                           Success: ^(id response) {
                                                             [DataManager storeUser: response[@"user"][@"id"]];
                                                             [DataManager storeDeviceToken:uuid];
                                                           }
                                                           Failure: ^(id failure){
                                                             //TODO
                                                           }];
    });
  }
}

+ (void)getUserSnaps:(NSString *)uuid Onsuccess:(void(^)(NSArray* responseObject))success Onfailure :(void(^)(NSError* error))failure {
    NSDictionary *params = @{ @"user" : @{ @"user_uuid" : uuid} };
    NSString *userId = [DataManager userID];

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

+ (void)createSnap:(NSDictionary *)params Onsuccess:(void(^)(NSDictionary* responseObject))success Onfailure :(void(^)(NSError* error))failure{
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"okjuxUserID"] != nil) {
    NSString *userId = [DataManager userID];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
      [[CommunicationManager sharedManager] sendPostRequestWithURL: [NSString stringWithFormat:@"%@users/%@/snaps", [CommunicationManager serverURL], userId]
                                                         AndParams: params
                                                           Success: ^(id response) {
                                                             dispatch_async(dispatch_get_main_queue(), ^(void){
                                                               NSLog(@"Success");
                                                             });
                                                           }
                                                           Failure: failure];
    });
  }
}

@end
