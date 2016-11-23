//
//  DataManager.h
//  okjux
//
//  Created by Camila Moscatelli on 11/21/16.
//
//

@interface DataManager : NSObject


#pragma mark Singleton
+ (id) getInstance;

#pragma mark User
+ (void)storeUser:(NSString *)userID;
+ (void)storeDeviceToken:(NSString*)token;
+ (void)storeCurrentLocation:(NSArray *)location;

+ (NSString*)userID;
+ (NSString*)deviceToken;
+ (NSString*)currentLocation;

@end
