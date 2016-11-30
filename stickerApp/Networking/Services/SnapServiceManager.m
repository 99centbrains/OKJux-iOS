//
//  SnapServiceManager.m
//  okjux
//
//  Created by Camila Moscatelli on 11/23/16.
//
//

#import "SnapServiceManager.h"
#import "DataManager.h"

@implementation SnapServiceManager


+ (void)getSnaps:(NSDictionary *)params OnSuccess:(void(^)(NSArray* responseObject ))success OnFailure :(void(^)(NSError* error))failure {

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[CommunicationManager sharedManager] sendGetRequestWithURL: [NSString stringWithFormat:@"%@snaps/", [CommunicationManager serverURL]]
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

+ (void)rankSnap:(NSInteger)snapID withLike:(BOOL)like OnSuccess:(void(^)(NSDictionary* responseObject ))success OnFailure :(void(^)(NSError* error))failure {
  if (![DataManager userExists]) {
    NSDictionary *params = @{ @"user": @{ @"userID" : [DataManager userID], @"UUID": [[[UIDevice currentDevice] identifierForVendor] UUIDString] } };
    NSString* url = [NSString stringWithFormat:@"%@snaps/%ld/%@", [CommunicationManager serverURL], (long)snapID, like ? @"like" : @"dislike"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
      [[CommunicationManager sharedManager] sendPostRequestWithURL: url
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
