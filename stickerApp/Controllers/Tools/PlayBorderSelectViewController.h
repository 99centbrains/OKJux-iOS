//
//  PlayBorderSelectViewController.h
//  catwang
//
//  Created by 99centbrains on 12/2/13.
//
//

#import <UIKit/UIKit.h>
#import "OkJuxViewController.h"

@class PlayBorderSelectViewController;

@protocol PlayBorderSelectViewControllerDelegate <NSObject>

- (void) playBorderSelectVCDone:(PlayBorderSelectViewController *)controller;
- (void) playBorderSelectVCChoseSize:(PlayBorderSelectViewController *)controller withSize:(int)size;
- (void) playBorderSelectVCChoseBorder:(PlayBorderSelectViewController *)controller withImage:(UIImage *)color;

@end


@interface PlayBorderSelectViewController : OkJuxViewController

@property (nonatomic, unsafe_unretained) id <PlayBorderSelectViewControllerDelegate> delegate;



@end
