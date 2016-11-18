//
//  CommunicationManager.m
//  okjux
//
//  Created by TopTier labs on 11/17/16.
//
//

#import "CommunicationManager.h"

@implementation CommunicationManager

+ (NSURL *)serverURL {
  return [NSURL URLWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"BaseURL"]];
}

+ (CommunicationManager* ) sharedManager {
  static CommunicationManager *_sharedClient = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedClient =  [[self alloc] initWithBaseURL:[self serverURL]];
  });
  
  return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  
  if (self) {
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
  }
  return self;
}

#pragma mark GET Request

- (void) sendGetRequestWithURL: (NSString*) url
                     AndParams: (NSDictionary * ) params
                       Success: (void (^)( id _responseObject ) ) success
                       Failure: (void (^)( NSError* _error ) ) _failure{
  
  [self GET:url parameters:params success:^(NSURLSessionDataTask *task, id response){
    if (success) {
      success(response);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error){
    if (_failure) {
      _failure(error);
    }
  }];
}

#pragma mark POST Request

- (void) sendPostRequestWithURL: (NSString*) url
                      AndParams: (NSDictionary *)params
                   AndMediaType: (NSString*)type
                        Success: (void (^)(id))_success
                        Failure: (void (^)(NSError *))_failure{
  
  if ([params objectForKey:@"snap"]){
    //TODO: change the names for the real keys
    NSString *name;
    NSString *fileName;
    __block NSData *dataMedia;
    dataMedia = [[params objectForKey:@"message"] objectForKey:@"media_files_attributes"];
    NSMutableDictionary *message = [[params objectForKey:@"message"] mutableCopy];
    [message removeObjectForKey:@"media_files_attributes"];
    params = @{ @"message": message };
    name = @"message[media]";
    fileName = [[message objectForKey:@"media_files_name"] lowercaseString];
    
    NSMutableURLRequest *request =
    [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      [formData appendPartWithFileData:dataMedia name:name fileName:[NSString stringWithFormat:@"%@.%@",fileName,ImageExtension] mimeType:ImageMimeType];
    } error:nil];
    
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = self.requestSerializer;
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       _success(responseObject);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       _failure(error);
                                     }];
    
    self.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html", @"application/json"]];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
      _failure([[NSError alloc] initWithDomain:@"Upload timed out." code:408 userInfo:nil]);
    }];
    
    [self.operationQueue addOperation:operation];
    
  }else {
    [self POST:url parameters:params success:^(NSURLSessionDataTask *task, id response){
      if (_success) {
        _success(response);
      }
    } failure:^(NSURLSessionDataTask *task, NSError *error){
      if (_failure) {
        _failure(error);
      }
    }];
  }
}

#pragma mark PUT Request

- (void) sendPutRequestWithURL: (NSString*) url
                     AndParams: (NSDictionary *)params
                       Success: (void (^)(id))_success
                       Failure: (void (^)(NSError *))_failure{
  
  [self PUT:url parameters:params success:^(NSURLSessionDataTask *task, id response){
    if (_success) {
      _success(response);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error){
    if (_failure) {
      _failure(error);
    }
  }];
}

#pragma mark DELETE Request

- (void) sendDeleteRequestWithURL: (NSString*) url
                        AndParams: (NSDictionary * ) params
                          Success: (void (^)( id _responseObject ) ) success
                          Failure: (void (^)( NSError* _error ) ) _failure{
  
  [self DELETE:url parameters:params success:^(NSURLSessionDataTask *task, id response){
    if (success) {
      success(response);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error){
    if (_failure) {
      _failure(error);
    }
  }];
}

@end
