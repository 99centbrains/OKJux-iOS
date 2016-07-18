//
//  AppDelegate.m
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "AppDelegate.h"
#import "ViewController.h"
#import "PlayViewController.h"
#import "Flurry.h"
#import "iNotify.h"
#import "iRate.h"
#import "iNotify.h"
#import "CBJSONDictionary.h"
#import <Parse/Parse.h>
#import "DataHolder.h"
#import "AppManager.h"
#import "HNKCache.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize navigationController;

+ (void)initialize {
    
    [iRate sharedInstance].daysUntilPrompt = 2;
    [iRate sharedInstance].usesUntilPrompt = 5;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
	[iNotify sharedInstance].notificationsPlistURL = kPlistURL;
    [iNotify sharedInstance].applicationVersion =  [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [iNotify sharedInstance].ignoreButtonLabel = @"X";
	[iNotify sharedInstance].showOnFirstLaunch = YES;
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (kJsonDebug){
        
        [[NSUserDefaults standardUserDefaults]
         setFloat:0.0f
         forKey:@"JSONVERSIONS"];
        
    }
    
    
    NSString *jsonUrl = [NSString stringWithFormat:kJSONScheme];
    [[CBJSONDictionary shared] getJSON:jsonUrl];
        
    ///SET UP VIEW CONTROLLER FOR NOTIFICATIONS
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *playVC = (ViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_ViewController"];
    self.viewController = playVC;
    
    application.applicationSupportsShakeToEdit = YES;
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    
    //SDKS
    
    [Chartboost startWithAppId:@"54e9f0a004b01637287765c9"
                  appSignature:@"cdaab4f41b9976c9b3c61085b845b30306254379"
                      delegate:self];
    
    
    
    //PARSE
    
    
    
    
    
    [Parse setApplicationId:@"dUW44SWxZv8z1lVd2ghaLSW8cpSSVk5VSGo55aI0"
                  clientKey:@"f1fUi29cX6hZwZNDMtN87Nnutf9FbPFUcKKTgcFV"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    [self setup_parse];

    [Flurry startSession:kFlurryKey];
    
    //PUSH NOTIFICATIONS
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    // register cache format for stickers
    HNKCacheFormat *format = [HNKCache sharedCache].formats[@"sticker"];
    if (!format)
    {
        format = [[HNKCacheFormat alloc] initWithName:@"sticker"];
        format.diskCapacity = 500 * 1024 * 1024; // 100MB
        format.preloadPolicy = HNKPreloadPolicyAll;
    }
    [[HNKCache sharedCache] registerFormat:format];
    
    return YES;
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSLog(@"APPLICATION OPENED %@", sourceApplication);

    if (url != nil && [url isFileURL]) {
        
        [self.viewController.navigationController popToRootViewControllerAnimated:NO];
        [self.viewController handleDocumentOpenURL:[url absoluteString]];
        return YES;
        
    }
    
    return YES;
    
}

#pragma PARSE SETUP
- (void) setup_parse{
    
    //USER COUNTRY
  //  NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    //NSLog(@"Country %@", countryCode);
    
   // NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    //NSLog(@"Timezone: %@", currentTimeZone.abbreviation);
    
    
    //PARSE USER
    [PFUser enableAutomaticUser];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    
    //SET UP CITY
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];

    
    
    currentInstallation[@"user"] = [PFUser currentUser];
   // NSLog(@"USER ID %@", [PFUser currentUser].objectId);
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    NSLog(@"***************** USER ID %@", [PFUser currentUser].objectId);
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]) {
        
                PFUser *currentUser = [PFUser currentUser];
                currentUser[@"points"] = [NSNumber numberWithInt:5];
                currentUser[@"banned"] = [NSNumber numberWithBool:NO];
                [currentUser save];
                
                [[CBJSONDictionary shared] parse_trackAnalytic:@{@"timezone":currentInstallation.timeZone} forEvent:@"Region"];
                [[NSUserDefaults standardUserDefaults] setObject:currentUser.objectId forKey:@"userid"];
                [DataHolder DataHolderSharedInstance].userObject = currentUser;
        
            } else{
        
                [[PFUser currentUser] fetchInBackground ];
                [DataHolder DataHolderSharedInstance].userObject = [PFUser currentUser];
                BOOL banned = [[DataHolder DataHolderSharedInstance].userObject[@"banned"] boolValue];
                [[NSUserDefaults standardUserDefaults] setBool:banned forKey:kUserBanStatus];

            }
        
        if (!succeeded){
            NSLog(@"PARSE FAILURE");
        }
        
    
    }];

}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:devToken];
    [currentInstallation saveInBackground];

}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [PFPush handlePush:userInfo];
    
    NSLog(@"remote notification: %@",[userInfo description]);
    
    
    if (application.applicationState == UIApplicationStateInactive) {

        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }

}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    // ...
}

-(void)processRemoteNotification:(NSDictionary*)userDict{
    
    
    [self.viewController dismissViewControllerAnimated:NO completion:nil];
    
    
    if( [userDict objectForKey:@"link"] != NULL){
        [self.viewController handleInternalURL:[userDict objectForKey:@"link"]];
        
    }
    
    if( [userDict objectForKey:@"site"] != NULL){
        [self.viewController handleExternalURL:[userDict objectForKey:@"site"]];
        
    }
    
    if( [userDict objectForKey:@"image"] != NULL){
        //[alertView show];
        [self.viewController handleDocumentOpenURL:[userDict objectForKey:@"image"]];
        
    }
    
}



- (void)askForPush{
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication]  registerForRemoteNotifications];

}
- (void)askForLocation{
    
    
    
    //LOCATION
    locationMgr =[[CLLocationManager alloc] init];
    locationMgr.delegate = self;
    locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationMgr requestWhenInUseAuthorization];

    [locationMgr startUpdatingLocation];
    
    
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        [DataHolder DataHolderSharedInstance].userGeoPoint = geoPoint;
        
        if (!error) {
            // do something with the new geoPoint
        }
    }];

}

- (void)setParseUser{

        [self setup_parse];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView.tag == 98 && buttonIndex == 1){
        
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];

    }
    
    
    
    if (alertView.tag == 20 && buttonIndex == 1){
        [self.viewController dismissViewControllerAnimated:NO completion:nil];
        
        if( [userInfoLocal objectForKey:@"link"] != NULL){
            [self.viewController handleInternalURL:[userInfoLocal objectForKey:@"link"]];
            
        }
        
        if( [userInfoLocal objectForKey:@"site"] != NULL){
            [self.viewController handleExternalURL:[userInfoLocal objectForKey:@"site"]];
            
        }
        
        if( [userInfoLocal objectForKey:@"image"] != NULL){
            //[alertView show];
            [self.viewController handleDocumentOpenURL:[userInfoLocal objectForKey:@"image"]];
            
        }
        
    }
    
}


#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Finding Location");

    [manager stopUpdatingLocation];

}

- (void)locationManager:(CLLocationManager *)manager
didStartMonitoringForRegion:(CLRegion *)region{
    
    NSLog(@"Finding Location");
    
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if (status == kCLAuthorizationStatusDenied) {
        
        [self requestAlwaysAuthorization];
    
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
    // Handle error
    [self requestAlwaysAuthorization];
    //[manager stopUpdatingLocation];
    
}

- (void)requestAlwaysAuthorization {
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

        if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined) {
            
           
        }
    
}



@end
