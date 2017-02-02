//
//  PlayEditModeViewController.h
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StickyImageView.h"
#import "OkJuxViewController.h"
@class PlayEditModeViewController;

@protocol PlayEditModeViewControllerDelegate <NSObject>

- (void) editModeLayerMoveUp:(PlayEditModeViewController *)controller;
- (void) editModeLayerMoveDown:(PlayEditModeViewController *)controller;

- (void) editModeStickerDone:(PlayEditModeViewController *)controller;
- (void) editModeStickerCopy:(PlayEditModeViewController*)controller;
- (void) editModeStickerSendToBack:(PlayEditModeViewController*)controller;
- (void) editModeStickerTrash:(PlayEditModeViewController*)controller;
- (void) editModeStickerFlip:(PlayEditModeViewController*)controller;

- (void) editModeBorderChose:(PlayEditModeViewController*)controller withBorder:(UIImage*)borderImage;



@end

@interface PlayEditModeViewController : OkJuxViewController <UIScrollViewDelegate>{

    

}
@property (nonatomic, strong) IBOutlet UIView *viewStickerEdit;

@property (nonatomic, unsafe_unretained) id <PlayEditModeViewControllerDelegate> delegate;

@end
