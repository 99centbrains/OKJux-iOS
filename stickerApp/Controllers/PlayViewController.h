//
//  PlayViewController.h
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectStickerQuickViewController.h"
#import "PlayEditModeViewController.h"
#import "ShareViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "OkJuxViewController.h"

@interface PlayViewController : OkJuxViewController <SelectStickerQuickViewControllerDelegate, UIGestureRecognizerDelegate, PlayEditModeViewControllerDelegate,ShareViewControllerDelegate, UIScrollViewDelegate>


@property (nonatomic) UIImage* userImage;
@end
