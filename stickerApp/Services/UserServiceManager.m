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
  if (![[NSUserDefaults standardUserDefaults] objectForKey:@"okjuxUserID"]) {
    NSDictionary *params = @{ @"user" : @{ @"user_uuid" : uuid} };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
      [[CommunicationManager sharedManager] sendPostRequestWithURL: [NSString stringWithFormat:@"%@users", [CommunicationManager serverURL]]
                                                         AndParams: params
                                                      AndMediaType: nil
                                                           Success: ^(id response) {
                                                             [[NSUserDefaults standardUserDefaults] setObject: response[@"user"][@"id"] forKey:@"okjuxUserID"];
                                                           }
                                                           Failure: ^(id failure){
                                                             //TODO
                                                           }];
    });
  }
}

@end
