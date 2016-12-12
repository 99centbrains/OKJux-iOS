//
//  CommunicationManager.h
//  okjux
//
//  Created by TopTier labs on 11/17/16.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "DataManager.h"

@interface CommunicationManager : AFHTTPSessionManager

@property (nonatomic, weak) id delegate;

+ (CommunicationManager *) sharedManager;
- (instancetype) initWithBaseURL:(NSURL *)url;
+ (NSURL *)serverURL;

- (void) sendGetRequestWithURL: (NSString*) url
                     AndParams: (NSDictionary*) params
                       Success: (void(^)(id _responseObject))_success
                       Failure: (void(^)(NSError* _error))_failure;

- (void) sendPostRequestWithURL: (NSString*) url
                      AndParams: (NSDictionary *)params
                        Success: (void (^)(id))_success
                        Failure: (void (^)(NSError *))_failure;

- (void) sendDeleteRequestWithURL: (NSString*) url
                      AndParams: (NSDictionary *)params
                        Success: (void (^)(id))_success
                        Failure: (void (^)(NSError *))_failure;

@end
