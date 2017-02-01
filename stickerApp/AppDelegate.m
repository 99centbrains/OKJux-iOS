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
#import "AppManager.h"
#import "HNKCache.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Instabug/Instabug.h>
#import "UserServiceManager.h"
#import "DataManager.h"
#import "Mixpanel/Mixpanel.h"

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
  
  //MIXPANEL
  [Mixpanel sharedInstanceWithToken:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Mixpanel_token"]];
  
  //MARK: NEW BACKEND
  [self sendUserInfo];
  
  //MARK: - SDKS
  [Chartboost startWithAppId:@"54e9f0a004b01637287765c9"
                appSignature:@"cdaab4f41b9976c9b3c61085b845b30306254379"
                    delegate:self];

  [Flurry startSession:kFlurryKey];

  //MARK: - INSTABUG
  [Instabug startWithToken:@"5d3b16ef9fae0c99ea3a4af6f3d62774" invocationEvent:IBGInvocationEventShake];
  
  //register cache format for stickers
  HNKCacheFormat *format = [HNKCache sharedCache].formats[@"sticker"];
  if (!format) {
    format = [[HNKCacheFormat alloc] initWithName:@"sticker"];
    format.diskCapacity = 500 * 1024 * 1024; // 100MB
    format.preloadPolicy = HNKPreloadPolicyNone;
  }
  [[HNKCache sharedCache] registerFormat:format];

  [Fabric with:@[[Crashlytics class]]];

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

#pragma mark Send user info

- (void)sendUserInfo {
  [self askForLocation];
  [UserServiceManager registerUserWith:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    //TODO when pushwoosh added
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
        //TODO when pushwoosh added
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
        //TODO when pushwoosh added
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //TODO when pushwoosh added
}

//TODO this method is never called
-(void)processRemoteNotification:(NSDictionary*)userDict {
    [self.viewController dismissViewControllerAnimated:NO completion:nil];
    if ([userDict objectForKey:@"link"] != NULL) {
        [self.viewController handleInternalURL:[userDict objectForKey:@"link"]];
    }

    if ([userDict objectForKey:@"site"] != NULL) {
        [self.viewController handleExternalURL:[userDict objectForKey:@"site"]];
    }

    if ([userDict objectForKey:@"image"] != NULL) {
        [self.viewController handleDocumentOpenURL:[userDict objectForKey:@"image"]];
    }
}

- (void)askForPush {
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication]  registerForRemoteNotifications];

}

- (void)askForLocation {
    locationMgr = [[CLLocationManager alloc] init];
    locationMgr.delegate = self;
    locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    [locationMgr requestWhenInUseAuthorization];
    [locationMgr startUpdatingLocation];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 98 && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }

    if (alertView.tag == 20 && buttonIndex == 1) {
        [self.viewController dismissViewControllerAnimated:NO completion:nil];
        if ([userInfoLocal objectForKey:@"link"] != NULL) {
            [self.viewController handleInternalURL:[userInfoLocal objectForKey:@"link"]];
        }

        if ([userInfoLocal objectForKey:@"site"] != NULL) {
            [self.viewController handleExternalURL:[userInfoLocal objectForKey:@"site"]];
        }

        if ([userInfoLocal objectForKey:@"image"] != NULL) {
            [self.viewController handleDocumentOpenURL:[userInfoLocal objectForKey:@"image"]];
        }
    }
}


#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  NSLog(@"Finding Location");
  NSArray *location = [NSArray arrayWithObjects:
                       [NSString stringWithFormat:@"%.8f", newLocation.coordinate.latitude],
                       [NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude], nil];
  [DataManager storeCurrentLocation: location];
  [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Finding Location");
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        [self requestAlwaysAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self requestAlwaysAuthorization];
}

- (void)requestAlwaysAuthorization {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"Access denied");
    }
}

@end
