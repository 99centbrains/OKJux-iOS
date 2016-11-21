//
//  DataManager.m
//  okjux
//
//  Created by Camila Moscatelli on 11/21/16.
//
//

#import <Foundation/Foundation.h>
#import "DataManager.h"

@implementation DataManager

#pragma mark Singleton

+ (id)getInstance {
    static DataManager * instance = nil;
    if (!instance) {
        instance = [[DataManager alloc] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark User
+ (void)storeUser:(NSString*)userID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userID forKey:@"okjuxUserID"];
    [defaults synchronize];
}

+ (NSString *)userID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"okjuxUserID"] stringValue];
}

+ (void)storeDeviceToken:(NSString *)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"okjuxDeviceToken"];
    [defaults synchronize];
}

+ (NSString*)deviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"okjuxDeviceToken"];
}

@end
