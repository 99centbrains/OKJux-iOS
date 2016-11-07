//
//  PlayPaintViewController.h
//  catwang
//
//  Created by 99centbrains on 12/2/13.
//
//

#import <UIKit/UIKit.h>

@class PlayPaintViewController;

@protocol PlayPaintViewControllerDelegate <NSObject>

- (void) playPaintVCDone:(PlayPaintViewController *)controller;
- (void) playPaintVCChangeSize:(PlayPaintViewController *)controller withSize:(NSInteger)size;
- (void) playPaintVCChangeMode:(PlayPaintViewController *)controller withMode:(BOOL)mode;
- (void) playPaintVCChangeColor:(PlayPaintViewController *)controller;

@end

@interface PlayPaintViewController : UIViewController

@property (nonatomic, unsafe_unretained) id <PlayPaintViewControllerDelegate> delegate;


@end
