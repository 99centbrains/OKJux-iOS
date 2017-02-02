//
//  ShareViewController.h
//  stickerApp
//
//  Created by Franky Aguilar on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>
#import "TAOverlay.h"
#import <StoreKit/StoreKit.h>
#import "DataManager.h"
#import "UserServiceManager.h"
#import "OkJuxViewController.h"

@class ShareViewController;

@protocol ShareViewControllerDelegate <NSObject>

- (void)shareViewDidComplete:(ShareViewController*)controller withMessage:(NSString *)message;

@end


@interface ShareViewController : OkJuxViewController

@property (nonatomic, strong) UIImage *userExportedImage;

@property (nonatomic, strong) NSString *assetContents;

@property (nonatomic, unsafe_unretained) id <ShareViewControllerDelegate> delegate;

@end
