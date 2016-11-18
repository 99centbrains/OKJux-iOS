//
//  CommunicationManager.h
//  okjux
//
//  Created by TopTier labs on 11/17/16.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface CommunicationManager : AFHTTPSessionManager

@property (nonatomic, weak) id delegate;

+ (CommunicationManager *) sharedManager;
- (instancetype)initWithBaseURL:(NSURL *)url;

@end
