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
  if (![DataManager userExists]) {
    NSDictionary *params = @{ @"user" : @{ @"UUID" : uuid} };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
      [[CommunicationManager sharedManager] sendPostRequestWithURL: [NSString stringWithFormat:@"%@users", [CommunicationManager serverURL]]
                                                         AndParams: params
                                                           Success: ^(id response) {
                                                             [DataManager storeKarma:response[@"user"][@"karma"]];
                                                             [DataManager storeUser: response[@"user"][@"id"]];
                                                             [DataManager storeDeviceToken:uuid];
                                                           }
                                                           Failure: ^(id failure){
                                                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                   //TODO
                                                                   NSLog(@"something went wrong");
                                                               });
                                                           }];
    });
  }
}

+ (void)getUserSnaps:(NSString *)uuid OnSuccess:(void(^)(NSArray* responseObject ))success OnFailure :(void(^)(NSError* error))failure {
    NSDictionary *params = @{ @"user" : @{ @"user_uuid" : uuid} };
    NSString *userId = [DataManager userID];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[CommunicationManager sharedManager] sendGetRequestWithURL: [NSString stringWithFormat:@"%@users/%@/snaps", [CommunicationManager serverURL], userId]
                                                          AndParams: params
                                                            Success: ^(id response) {
                                                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                    NSArray *snaps = [Snap parseSnapsFromAPIData: response];
                                                                    success(snaps);
                                                                });
                                                            }
                                                            Failure: ^(NSError* error) {
                                                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                    failure(error);
                                                                });
                                                            }];
    });
}

+ (void)createSnap:(NSDictionary *)params Onsuccess:(void(^)(NSDictionary* responseObject))success Onfailure :(void(^)(NSError* error))failure{
  if ([DataManager userExists]) {
    NSString *userId = [DataManager userID];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
      [[CommunicationManager sharedManager] sendPostRequestWithURL: [NSString stringWithFormat:@"%@users/%@/snaps", [CommunicationManager serverURL], userId]
                                                         AndParams: params
                                                           Success: ^(id response) {
                                                             dispatch_async(dispatch_get_main_queue(), ^(void){
                                                               success(response);
                                                             });
                                                           }
                                                           Failure: failure];
    });
  }
}

+ (void)deleteSnap:(NSInteger)snapID OnSuccess:(void(^)(NSDictionary* responseObject ))success OnFailure :(void(^)(NSError* error))failure {
  if ([DataManager userExists]) {
    NSDictionary *params = @{ @"user": @{ @"UUID": [DataManager deviceToken] } };
    NSString* url = [NSString stringWithFormat:@"%@users/%@/snaps/%ld", [CommunicationManager serverURL], [DataManager userID], (long)snapID];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
      [[CommunicationManager sharedManager] sendDeleteRequestWithURL: url
                                                           AndParams: params
                                                             Success: ^(id response) {
                                                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                 success(response);
                                                               });
                                                             }
                                                             Failure: ^(NSError* error){
                                                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                 failure(error);
                                                               });
                                                             }];
    });
  }
}

@end
