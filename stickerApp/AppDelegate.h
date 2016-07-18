//
//  AppDelegate.h
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Chartboost/Chartboost.h>
#import <AdColony/AdColony.h>

@class ViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, ChartboostDelegate, AdColonyDelegate, CLLocationManagerDelegate>{
    
    NSDictionary *userInfoLocal;
    CLLocationManager *locationMgr;

    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property(nonatomic,assign) CLLocationCoordinate2D myLocation;



- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;


- (void)askForPush;
- (void)askForLocation;
- (void)setParseUser;

@end
