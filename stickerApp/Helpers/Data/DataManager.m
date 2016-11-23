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

+ (void)storeCurrentLocation:(NSArray *)location {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:location[0] forKey:@"okjuxLatitude"];
  [defaults setObject:location[1] forKey:@"okjuxLongitude"];
  [defaults synchronize];
}

+ (NSString*)currentLocation {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [NSString stringWithFormat:@"(%@,%@)", [defaults objectForKey:@"okjuxLatitude"], [defaults objectForKey:@"okjuxLongitude"]];
}

@end
